from ranger.api.commands import Command

import platform

is_darwin = platform.system() == 'Darwin'


class mkcd(Command):
    """
    :mkcd <dirname>
    Creates a directory with the name <dirname> and enters it.
    """

    def execute(self):
        from os.path import join, expanduser, lexists
        from os import makedirs
        import re

        dirname = join(self.fm.thisdir.path, expanduser(self.rest(1)))
        if not lexists(dirname):
            makedirs(dirname)

            match = re.search('^/|^~[^/]*/', dirname)
            if match:
                self.fm.cd(match.group(0))
                dirname = dirname[match.end(0):]

            for m in re.finditer('[^/]+', dirname):
                s = m.group(0)
                if s == '..' or (s.startswith('.') and not self.fm.settings['show_hidden']):
                    self.fm.cd(s)
                else:
                    # We force ranger to load content before calling `scout`.
                    self.fm.thisdir.load_content(schedule=False)
                    self.fm.execute_console('scout -ae ^{}$'.format(s))
        else:
            self.fm.notify('file/directory exists!', bad=True)


class du(Command):
    """
    :du
    Runs dust on the current selection.
    """

    def execute(self):
        import subprocess
        import tempfile

        width = str(self.fm.ui.termsize[1])

        selection = [fl.path for fl in self.fm.thistab.get_selection()]

        dust = subprocess.Popen(
            ['dust', '-r', '-w', width, *selection],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL
        )
        dust_stdout, _ = dust.communicate()

        with tempfile.NamedTemporaryFile('wb', prefix='ranger_command_du_dust_output.') as tf:
            tf.write(dust_stdout)
            tf.flush()
            less = self.fm.execute_command(['less', '-Rmc', '--', tf.name], stderr=subprocess.DEVNULL)
            less.communicate()


if is_darwin:
    class trash(Command):
        """:trash

        Moves the selection to the trash (Darwin only).
        """

        allow_abbrev = False
        escape_macros_for_shell = True

        def execute(self):
            import shlex
            from functools import partial
            import os

            def is_directory_with_files(path):
                return os.path.isdir(path) and not os.path.islink(path) and len(os.listdir(path)) > 0

            if self.rest(1):
                file_names = shlex.split(self.rest(1))
                files = self.fm.get_filesystem_objects(file_names)
                if files is None:
                    return
                many_files = (len(files) > 1 or is_directory_with_files(files[0].path))
            else:
                cwd = self.fm.thisdir
                tfile = self.fm.thisfile
                if not cwd or not tfile:
                    self.fm.notify("Error: no file selected for deletion!", bad=True)
                    return

                files = self.fm.thistab.get_selection()
                # relative_path used for a user-friendly output in the confirmation.
                file_names = [f.relative_path for f in files]
                many_files = (cwd.marked_items or is_directory_with_files(tfile.path))

            confirm = self.fm.settings.confirm_on_delete
            if confirm != 'never' and (confirm != 'multiple' or many_files):
                self.fm.ui.console.ask(
                    "Confirm deletion of: %s (y/N)" % ', '.join(file_names),
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
                self._trash_file(f.path)

        @staticmethod
        def _trash_file(file_path):
            import subprocess
            script = f'''
            tell application "Finder"
                delete (POSIX file "{file_path}" as alias)
            end tell
            '''
            subprocess.run(['osascript', '-e', script], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
