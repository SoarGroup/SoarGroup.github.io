# This file is used by Mkdocs-Macros to define macros that can be used in the
# markdown files. The macros are defined in the `define_env` function and can
# be used in the markdown files by using the `{{macro_name}}` syntax.

def define_env(env):
    "Defines macros for Mkdocs-Macros"

    def soar_version():
        # mkdocs-macros exposes `extra` values via env.variables; Zensical's
        # macros shim only exposes them via env.conf["extra"].
        try:
            return env.variables["soar_version"]
        except (AttributeError, KeyError):
            return env.conf["extra"]["soar_version"]

    @env.macro
    def tutorial_wip_warning(file_name):
        # Emitted as an admonition rather than a heading so it does not add a
        # second <h1> to the page, which suppresses the "On this page" outline.
        file_name = file_name.strip()
        url = (
            "https://github.com/SoarGroup/Soar/releases/download/"
            f"releases%2F{soar_version()}/{file_name}"
        )
        return (
            '!!! warning "Under Construction"\n\n'
            "    The HTML version of the tutorial is currently under "
            "construction; in particular, the figure annotations are missing. "
            f"You may wish to view the PDF version [here]({url}) instead.\n"
        )
