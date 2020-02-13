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
