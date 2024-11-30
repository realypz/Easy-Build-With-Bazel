""" Rules for running shell script that print a given text. """

def _get_full_label(label):
    return "@@" + label.workspace_root + "//" + label.package + ":" + label.name

def _print_in_shell_impl(ctx):
    # https://bazel.build/extending/rules#declaring_outputs
    #
    # Declare the output file that will be created by this rule
    # You have to explicitly tell Bazel to generate it.
    output_sh = ctx.actions.declare_file(ctx.label.name + ".sh")

    # Actions: https://bazel.build/extending/rules#actions
    # An action describes how to generate a set of outputs from a set of inputs.
    # When an action is created, Bazel doesn't run the command immediately.
    # It registers it in a graph of dependencies, because an action can depend on the output of another action.

    # actions (https://bazel.build/rules/lib/builtins/actions, be accessed by ctx.action) is a module
    # provides file creation actions.
    ctx.actions.write(
        output = output_sh,
        content = "echo 'Target {} says:\n{}'\n".format(
            _get_full_label(ctx.label),

            # Attributes: https://bazel.build/extending/rules#attributes
            #
            # An attribute is a rule argument defined in the rule's attrs dict.
            # E.g. ctx.attr.text mapps to the "text" attribute in the `attrs`
            #      dict of the rule `print_in_shell` below.
            #
            # NOTE: ctx.attr is a struct (https://bazel.build/rules/lib/builtins/ctx#attr),
            #       which is different from the top-level `attr` module
            #       (https://bazel.build/rules/lib/toplevel/attr.html).
            ctx.attr.text,
        ),
        is_executable = True,
    )

    # Providers: https://bazel.build/extending/rules#providers
    #
    # Providers are pieces of information that a rule exposes to other rules that depend on it.
    # This data can include output files, libraries, parameters to pass on a tool's command line,
    # or anything else a target's consumers should know about.
    #
    # The list of built-in providers can be found at https://bazel.build/rules/lib/providers.
    # You can also define your own providers by provider function https://bazel.build/rules/lib/globals/bzl.html#provider.

    # DefaultInfo is one of the built-in providers.
    return DefaultInfo(
        files = depset([output_sh]),

        # Define the executable file to be invoked
        # when the rule is invoked by bazel "run" command.
        executable = output_sh,
    )

print_in_shell = rule(
    implementation = _print_in_shell_impl,
    attrs = {
        # You can create your own attributes by invoking the attr module.
        # E.g. attr.string (https://bazel.build/rules/lib/toplevel/attr.html#string)
        "text": attr.string(mandatory = True),
    },

    # Determines whether the rule can be invoked by bazel "run" command or not.
    # The executable path is defined by the "executable" attribute of DefaultInfo.
    executable = True,
)

def greeting_binary_macro(name, plannet, greeting, visibility = None):
    # Do some string manipulation
    greating_text = greeting + " from " + plannet + "!"

    # Instantiate a rule
    print_in_shell(
        name = name,
        text = greating_text,
        visibility = visibility,
    )
