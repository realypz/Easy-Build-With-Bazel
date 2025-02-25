"""
Save the OS information to a txt file.
"""

def _os_info_impl(ctx):
    output_filename = ctx.attr.output_file

    if (output_filename.endswith(".txt") == False):
        fail("Output file must end with .txt")

    output_file = ctx.actions.declare_file(ctx.attr.output_file)

    ctx.actions.run_shell(
        outputs = [output_file],
        command = """
        uname -a > {output_file}
        """.format(output_file = output_file.path),
    )

    return DefaultInfo(
        files = depset([output_file]),
    )

os_info = rule(
    implementation = _os_info_impl,
    attrs = {
        "output_file": attr.string(
            mandatory = True,
            doc = "The output file to write the OS information to, shall end with .txt",
        ),
    },
)
