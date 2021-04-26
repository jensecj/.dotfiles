import os
from ranger.core.loader import CommandLoader
from ranger.api.commands import *


class tar(Command):
    def execute(self):
        """ Compress marked files in current buffer """
        cwd = self.fm.thisdir
        marked_files = cwd.get_selection() or []

        if not marked_files:
            return

        def refresh(_):
            cwd = self.fm.get_directory(original_path)
            cwd.load_content()

        original_path = cwd.path
        parts = self.line.split()
        args = parts[1:] if parts else ""

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


class shred(Command):
    def execute(self):
        """ Compress marked files in current buffer """
        if self.rest(1):
            self.fm.notify(
                "Error: shred takes no arguments! It shreds the selected file(s).",
                bad=True,
            )
            return

        cwd = self.fm.thisdir
        cf = self.fm.thisfile

        many_files = cwd.marked_items or (
            cf.is_directory and not cf.is_link and len(os.listdir(cf.path)) > 0
        )

        marked_files = cwd.get_selection() or cf

        if not marked_files:
            self.fm.notify("Error: no file selected for shredding!", bad=True)
            return

        self.fm.ui.console.ask(
            "Confirm shredding of: %s (y/n)"
            % ", ".join(f.basename for f in marked_files),
            self._question_callback,
        )

    def _question_callback(self, answer):
        if answer.lower() != "y":
            return

        original_path = self.fm.thisdir

        def refresh(_):
            cwd = self.fm.get_directory(original_path)
            cwd.load_content()

        marked_files = self.fm.thisdir.get_selection() or self.fm.thisfile

        args = ["shred", "-u"] + [os.path.abspath(f.path) for f in marked_files]
        obj = CommandLoader(args=args, read=True, descr="shred files")
        obj.signal_bind("after", refresh)

        self.fm.loader.add(obj)
        self.fm.notify("shredding!")


class fzf_select(Command):
    """
    :fzf_select
    Find a file using fzf.
    With a prefix argument to select only directories.

    See: https://github.com/junegunn/fzf
    """

    def execute(self):
        import subprocess
        from ranger.ext.get_executables import get_executables

        if "fzf" not in get_executables():
            self.fm.notify("Could not find fzf in the PATH.", bad=True)
            return

        fd = "fd" if "fd" in get_executables() else None

        if fd is not None:
            hidden = "--hidden" if self.fm.settings.show_hidden else ""
            exclude = "--no-ignore-vcs --exclude '.git' --exclude '*.py[co]' --exclude '__pycache__'"
            only_directories = "--type directory" if self.quantifier else ""
            fzf_default_command = "{} --follow {} {} {} --color=always".format(
                fd, hidden, exclude, only_directories
            )
        else:
            hidden = (
                "-false" if self.fm.settings.show_hidden else r"-path '*/\.*' -prune"
            )
            exclude = r"\( -name '\.git' -o -iname '\.*py[co]' -o -fstype 'dev' -o -fstype 'proc' \) -prune"
            only_directories = "-type d" if self.quantifier else ""
            fzf_default_command = (
                "find -L . -mindepth 1 {} -o {} -o {} -print | cut -b3-".format(
                    hidden, exclude, only_directories
                )
            )

        env = os.environ.copy()
        env["FZF_DEFAULT_COMMAND"] = fzf_default_command
        env[
            "FZF_DEFAULT_OPTS"
        ] = '--height=40% --layout=reverse --ansi --preview="{}"'.format(
            """
            (
                batcat --color=always {} ||
                bat --color=always {} ||
                cat {} ||
                tree -ahpCL 3 -I '.git' -I '*.py[co]' -I '__pycache__' {}
            ) 2>/dev/null | head -n 100
        """
        )

        fzf = self.fm.execute_command(
            "fzf --no-multi", env=env, universal_newlines=True, stdout=subprocess.PIPE
        )
        stdout, _ = fzf.communicate()
        if fzf.returncode == 0:
            selected = os.path.abspath(stdout.strip())
            if os.path.isdir(selected):
                self.fm.cd(selected)
            else:
                self.fm.select_file(selected)
