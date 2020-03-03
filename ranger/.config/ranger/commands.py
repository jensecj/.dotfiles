import os
from ranger.core.loader import CommandLoader
from ranger.api.commands import *


class tar(Command):
    def execute(self):
        """ Compress marked files in current buffer """
        cwd = self.fm.thisdir
        marked_files = cwd.get_selection()

        if not marked_files:
            return

        def refresh(_):
            cwd = self.fm.get_directory(original_path)
            cwd.load_content()

        original_path = cwd.path
        parts = self.line.split()
        args = parts[1:]

        desc = "archiving files in: " + os.path.basename(parts[1])
        obj = CommandLoader(
            args=["tar", "czf"]
            + args
            + [os.path.relpath(f.path, cwd.path) for f in marked_files],
            descr=desc,
            read=True,
        )

        obj.signal_bind("after", refresh)
        self.fm.loader.add(obj)

        self.fm.notify("compressed!")

    def tab(self):
        cwd = self.fm.thisdir.path
        return str(os.path.basename(cwd)) + ".tar.gz"
class fzf_select(Command):
    """
    :fzf_select

    Find a file using fzf.

    With a prefix argument select only directories.

    See: https://github.com/junegunn/fzf
    """

    def execute(self):
        import subprocess
        import os.path

        if self.quantifier:
            # match only directories
            command = "find -L . \( -path '*/\.*' -o -fstype 'dev' -o -fstype 'proc' \) -prune \
            -o -type d -print 2> /dev/null | sed 1d | cut -b3- | fzf +m"
        else:
            # match files and directories
            command = "find -L . \( -path '*/\.*' -o -fstype 'dev' -o -fstype 'proc' \) -prune \
            -o -print 2> /dev/null | sed 1d | cut -b3- | fzf +m"
        fzf = self.fm.execute_command(
            command, universal_newlines=True, stdout=subprocess.PIPE
        )
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.rstrip("\n"))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)
