def define_env(env):
    "Defines macros for Mkdocs-Macros"

    @env.macro
    def tutorial_wip_warning(file_name):
        return (
            "# 🚧 Under Construction 🚧\n The HTML version of the tutorial "
            "is currently under construction. If you find it difficult to "
            "read, the PDF of this chapter is available "
            f"[here](https://github.com/SoarGroup/Soar/releases/download/releases%2F9.6.2/{file_name})."
        )
