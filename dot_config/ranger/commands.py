import os

from ranger.api.commands import Command


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
                    ## We force ranger to load content before calling `scout`.
                    self.fm.thisdir.load_content(schedule=False)
                    self.fm.execute_console('scout -ae ^{}$'.format(s))
        else:
            self.fm.notify('file/directory exists!', bad=True)


class du(Command):
    def execute(self):
        import subprocess
        import tempfile
        import os

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
