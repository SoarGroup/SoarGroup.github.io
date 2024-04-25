def define_env(env):
    "Defines macros for Mkdocs-Macros"

    @env.macro
    def tutorial_wip_warning(file_name):
        return (
            "# 🚧 Under Construction 🚧\n The HTML version of the tutorial "
            "is currently under construction; in particular, the figure "
            "annotations are missing. You may wish to view the PDF version "
            f"[here](https://github.com/SoarGroup/Soar/releases/download/releases%2F{env.variables['soar_version']}/{file_name}) "
            "instead."

        )
