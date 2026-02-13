from __future__ import absolute_import, division, print_function

import os
import platform
import re
import shlex
import shutil
import subprocess
from functools import partial
from pathlib import Path

from ranger.api.commands import Command

# Check if the current OS is macOS
IS_DARWIN = platform.system() == 'Darwin'


class mkcd(Command):
    """
    :mkcd <dirname>

    Creates a directory with the name <dirname> and enters it.
    This command is more robust than a simple `mkdir && cd` because it handles
    ranger's internal state and ensures the UI stays in sync.
    """

    def execute(self):
        # 1. Parse and resolve the target path
        input_path = self.rest(1)
        if not input_path:
            self.fm.notify('Usage: mkcd <dirname>', bad=True)
            return

        try:
            base_path = Path(self.fm.thisdir.path)
            # Handle home directory expansion (~) and resolve to absolute path
            expanded_input = os.path.expanduser(input_path)
            input_path_obj = Path(expanded_input)

            if input_path_obj.is_absolute():
                target_path = input_path_obj.resolve()
            else:
                target_path = (base_path / input_path_obj).resolve()
        except Exception as e:
            self.fm.notify(f'Path resolution error: {e}', bad=True)
            return

        # 2. Create the directory if it doesn't exist
        if target_path.exists() and target_path.is_file():
            self.fm.notify(f"'{target_path}' exists and is a file!", bad=True)
            return

        try:
            target_path.mkdir(parents=True, exist_ok=True)
        except Exception as e:
            self.fm.notify(f'Failed to create directory: {e}', bad=True)
            return

        # 3. Calculate navigation steps from current directory
        # We use a "common ancestor" approach to allow navigating from the current
        # position using '..' and then moving down into the target.
        try:
            common = Path(os.path.commonpath([str(base_path), str(target_path)]))
        except ValueError:
            # This can happen on different drives/roots (less common on Unix)
            self.fm.cd(str(target_path))
            return

        # Steps to go up from current directory to the common ancestor
        up_steps = []
        curr = base_path
        while curr != common:
            up_steps.append('..')
            curr = curr.parent

        # Steps to go down from the common ancestor to the target directory
        down_steps = target_path.relative_to(common).parts

        # 4. Execute navigation with UI synchronization
        # We navigate step-by-step to ensure Ranger's UI (breadcrumbs, previews)
        # stays perfectly in sync with the filesystem changes.

        # Navigate up using standard 'cd ..' as it's the most reliable way to move out
        for _ in up_steps:
            self.fm.cd('..')

        # Navigate down using 'scout' to provide a smoother visual transition
        for part in down_steps:
            if not part or part == '.':
                continue

            # For hidden directories or special cases, use standard cd
            if part.startswith('.') and not self.fm.settings['show_hidden']:
                self.fm.cd(part)
            else:
                # Force Ranger to refresh its directory cache so 'scout' can find the new dir
                self.fm.thisdir.load_content(schedule=False)
                # 'scout -ae' simulates a precise search and enter, which triggers
                # Ranger's UI hooks for selection and smooth scrolling.
                self.fm.execute_console(f'scout -ae ^{re.escape(part)}$')

        # 5. Final UI refresh to ensure the titlebar and status bar show the new path
        self.fm.ui.redraw_main_column()
        self.fm.ui.status.request_redraw()
        self.fm.ui.titlebar.request_redraw()

    def tab(self, tabnum):
        return self._tab_directory_content()


class du(Command):
    """
    :du

    Runs `dust` (a more intuitive `du` alternative) on the current selection.
    The output is displayed using `less` to allow for easy scrolling and
    searching of the disk usage results.
    """

    def execute(self):
        # 1. Check if 'dust' is installed
        if shutil.which('dust') is None:
            self.fm.notify(
                "Error: 'dust' not found. Please install it first.",
                bad=True,
            )
            return

        # 2. Prepare the selection and terminal width
        width = str(self.fm.ui.termsize[1])
        selection = [fl.path for fl in self.fm.thistab.get_selection()]

        if not selection:
            return

        # 3. Execute dust and pipe its output directly to less using subprocess
        # We connect dust's stdout to less's stdin to create a streaming pipeline.
        # This avoids loading large output into memory and keeps the UI responsive.
        dust_proc = subprocess.Popen(
            ['dust', '-r', '-w', width, *selection],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )

        # Use execute_command to run 'less' within ranger's UI context.
        # By passing dust's stdout as stdin, data flows directly between processes
        # without being buffered in Python's memory.
        less_proc = self.fm.execute_command(
            ['less', '-Rmc'],
            stdin=dust_proc.stdout,
            stderr=subprocess.DEVNULL,
        )

        # Close the stdout in the parent process so it can receive SIGPIPE if less exits
        dust_proc.stdout.close()
        less_proc.communicate()


if IS_DARWIN:

    class trash(Command):
        """
        :trash

        Moves the selection to the macOS Trash using AppleScript.
        This is preferred over `rm` because:
        1. It's reversible (files go to the system Trash).
        2. It uses the system's native deletion logic via Finder.
        """

        allow_abbrev = False
        escape_macros_for_shell = True

        def execute(self):
            def is_directory_with_files(path):
                return (
                    os.path.isdir(path)
                    and not os.path.islink(path)
                    and len(os.listdir(path)) > 0
                )

            if self.rest(1):
                files = shlex.split(self.rest(1))
                if files is None:
                    return
                many_files = len(files) > 1 or is_directory_with_files(files[0])
            else:
                cwd = self.fm.thisdir
                tfile = self.fm.thisfile
                if not cwd or not tfile:
                    self.fm.notify('Error: no file selected for deletion!', bad=True)
                    return

                files = self.fm.thistab.get_selection()
                # relative_path used for a user-friendly output in the confirmation.
                file_names = [f.relative_path for f in files]
                many_files = cwd.marked_items or is_directory_with_files(tfile.path)

            confirm = self.fm.settings.confirm_on_delete
            if confirm != 'never' and (confirm != 'multiple' or many_files):
                self.fm.ui.console.ask(
                    'Confirm deletion of: %s (y/N)' % ', '.join(file_names),
                    partial(self._question_callback, files),
                    ('n', 'N', 'y', 'Y'),
                )
            else:
                # no need for a confirmation, just delete
                self._trash_files(files)

        def tab(self, tabnum):
            return self._tab_directory_content()

        def _question_callback(self, files, answer):
            if answer.lower() == 'y':
                self._trash_files(files)

        def _trash_files(self, files):
            for f in files:
                # Some objects in 'files' might be ranger.container.file.File objects,
                # others might be strings if passed via command line arguments.
                path = f.path if hasattr(f, 'path') else f
                self._trash_file(path)

        @staticmethod
        def _trash_file(file_path):
            # Using AppleScript to tell Finder to delete the file.
            # This is the "official" way to move things to Trash on macOS.
            script = f'''
            tell application "Finder"
                delete (POSIX file "{file_path}" as alias)
            end tell
            '''
            subprocess.run(
                ['osascript', '-e', script],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )

    class copy_content(Command):
        """
        :copy_content

        Copies the content of the current file to the macOS clipboard using `pbcopy`.
        This is an efficient way to grab configuration or code snippets without
        opening an editor.
        """

        def execute(self):
            file = self.fm.thisfile
            if not file:
                self.fm.notify('No file selected!', bad=True)
                return

            if not os.path.isfile(file.path):
                self.fm.notify('Selected item is not a file!', bad=True)
                return

            try:
                # Use pbcopy to put file content into system clipboard.
                # By piping the file handle directly to pbcopy's stdin, we ensure
                # high performance and minimal memory usage even for large files.
                with open(file.path, 'rb') as f:
                    subprocess.run(['pbcopy'], stdin=f, check=True)
                self.fm.notify(f'Copied content of {file.relative_path} to clipboard.')
            except (subprocess.CalledProcessError, IOError):
                self.fm.notify('Failed to copy content to clipboard!', bad=True)
