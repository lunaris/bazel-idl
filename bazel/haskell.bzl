load("@io_tweag_rules_haskell//haskell:haskell.bzl", "haskell_library")

def haskell_avro_library(name, idl, module, **kwargs):
    sources_name = name + "@sources"
    sources_label = ":" + sources_name

    module_file = module + ".hs"

    library_name = name

    native.genrule(
        name = sources_name,
        srcs = [idl],
        outs = [module_file],
        cmd = "./$(location //tools:avro.sh) $(location {idl}) {module} > \"$@\"".format(
            idl = idl,
            module = module,
        ),
        tools = [
            "//tools:avro.sh",
        ],
    )

    haskell_library(
        name = name,
        srcs = [
            sources_label
        ],
        **kwargs
    )
