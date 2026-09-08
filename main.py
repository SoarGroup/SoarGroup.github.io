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
        return (
            "# 🚧 Under Construction 🚧\n The HTML version of the tutorial "
            "is currently under construction; in particular, the figure "
            "annotations are missing. You may wish to view the PDF version "
            f"[here](https://github.com/SoarGroup/Soar/releases/download/releases%2F{soar_version()}/{file_name}) "
            "instead."

        )
