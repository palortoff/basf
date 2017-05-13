# BaSF - Bash Scripting Framework

basf is a minimalist framework to write command line applications under the
umbrella of the basf command, organized in modules and with a simple and unique
interface.

The typical invocation of basf on the command prompt is:

```shell
$ basf <module> <action> [options...]
```

## Bootstrapping the application

The simplest way to bootstrap the application is to simply source the `basf` main file `basf`

```shell
#!/bin/bash

source /path/to/basf/basf
```

## Modules

A module is a container that organizes a set of related commands - the actions.

From the user perspective, the call of a module and it's action is similar to
call a command on the command line. But instead of grouping several related
commands loosely by a similar name, a module groups this commands into the same
namespace.

In addition to the actions a module provides typically other common information,
such a description and a help.

Bash and therefore modules supports inheritance and each module automatically
inherits from `default.bsl` module (it is located in the `libs/` directory).

#### Actions

Actions are functions that can be called by the user. Or if you think OOP,
then you can also say that these are the public methods of your modules.

Within a module a normal bash function is an action if it starts with
the prefix `do_`. A action can request any parameter like every other function
within the `$@` variable and that works as expected. I.e. every value after
`<action>` is passed as a parameter to the action.

There are also some predefined actions. These are:
- usage
- version
- help

These actions do what they obviously should do.
You can overwrite this actions but usually there is no good reason to do it.

The default implementation of these functions can be found in
`libs/default.bsl`.

#### Default action

There are several ways to control the behavior when the module was called
without specifying an action.

First, there is the default behavior. If nothing else works, then the function
`do_help` is called. This function is already defined in the base file and
therefore pretty sure available.

The first way to change this behavior is to set another default action
using `DEFAULT_ACTION` as described above.

The second, not recommended, way is the most obvious - overwrite
the do_help function.

A third possibility is to implement the `__module` function.

#### Fallback action

By default, an error is thrown when the requested action was not found.
However, if a function `__action` exists, then this function is called instead.

Notice that this function is called for all unknown actions, but not if
no action is specified at all. For that case look at the default action section.


#### Module configuration

The following variables are optional.

- `DESCRIPTION`

  Description of this module. Defaults empty

- `DEFAULT_ACTION`

  The default action of the module if none is given. Defaults to `help`

- `VERSION`

  The version of this module. Defaults to `0.1.0`

- `HIDDENMODULE`

  Hide this module in the module overview if set to 1. Defaults to 0

#### Parameters

Parameters to an action are defined in the `describe_<action>_parameters`
function.

```shell
describe_has_parameters() {
    echo "<module>"
}
```

Parameters are accessed via the `${@}` variables.

Parameters are displayed in the help.

```
Extra actions:
  has <module>              Return true if the module or alias is installed, otherwise false.
```

#### Options

Options of an action are defined in the `describe_<action>_options` function
using the `make_option` function.

```shell
describe_list_options() {
    make_option --name "only_names" --long "only-names" --short "n" --desc "Output names of modules only"
    make_option --name "all"        --long "all"        --short "a" --desc "Do not omit hidden modules"
}
```

Options are displayed in the help.

```
Extra actions:
  list                      List all available modules
    -n --only-names           Output names of modules only
    -a --all                  Do not omit hidden modules
```

Options are accessed within the the action with `has_option`

```shell
if has_option "only_names" $@; then
    # optional code here...
fi
```

Currently only flag options are supported. Options with parameters are covered
in #16

#### Hiding actions

Sometimes it can be useful to hide actions from the help page. To hide an action
define a `hide_<action>` function that returns a zero exit code.

## Aliases

Aliases are lightweight modules that are used without actions. Aliases make use
of the `__module` function defined in the `alias.bsl` library.

Aliases are defined by declaring the variables `ALIAS_MODULE` and `ALIAS`.

By inheriting the `alias` library the `__module` function and the `help` action
are defined.

- `ALIAS_MODULE`

  Defines the module the alias is a shortcut for. This is only used for the help.

- `ALIAS`

  The module, action, parameters and options of the alias. Will be invoked in
  the __modules function.

Other module configurations like `DESCRIPTION`, `VERSION` and `HIDDENMODULE` are
available. However, `DEFAULT_ACTION` cannot be used as the `__module` function
is used.

## Libraries

Libraries are used to group reusable functions. Libraries are devined in .bsl
files in the library directories.

To use a library in a module load it using the inherit function.

```
inherit config tests output
```

There are several predefined libraries as described below
- `alias`
- `config`
- `core`
- `default`
- `environment`
- `git`
- `output`
- `tests`

#### The `alias` library

The alias library is used for aliases that are defined using the `ALIAS_MODULE`
and `ALIAS` variables.

#### The `config` library

Library functions for working with configuration files.

- `read_config_value`

  Load the value for key `key` from a configuration file `file`.

  Parameters:
  - file The file to read from
  - key The key

  Note:

  The configuration file must be a valid bash script, that is,
  the file must be loadable with `source $file`.

#### The `core` library

Core contains functions used by the basf core. The core library is not intended
to be used in modules.

#### The  `default` library

The default library is the 'base class' for modules. Here default actions  and
default module behavior is defined.

#### The `environment` library

The environment library provides functions to query the application's
environment.

- `environment_platform`

  Echoes the platform provided by `uname`. Examples are 'linux' or 'mingw64'.

- `environment_is_root`

  Returns zero if the application is called with root privileges, non-zero
  otherwise.

#### The `git` library

Provides helpful functions related to git.

- `environment_platform`
- `git_current_branch`
- `git_tracking_branch`
- `git_changes`
- `git_has_empty_index`
- `git_has_clean_stage`
- `git_has_untracked_files`
- `git_has_unstaged`
- `git_wc_root`
- `git_editor`
- `git_pager`

#### The `output` library

The output library provides functions for colored and structured output

Colored and highlighted lines:
- `write_bold`
- `write_bold_red`
- `write_norm_red`
- `write_bold_green`
- `write_norm_green`
- `write_bold_yellow`
- `write_norm_yellow`
- `write_bold_blue`
- `write_norm_blue`
- `write_bold_magenta`
- `write_norm_magenta`
- `write_bold_cyan`
- `write_norm_cyan`
- `write_bold_white`
- `write_norm_white`
- `write_norm_highlight`
- `write_bold_highlight`

Centered blocks with a fixed width containing a fixed word. Call with any
argument to add brackets:

- `write_block_done`
- `write_block_ok`
- `write_block_skip`
- `write_block_fail`

Prefixed messages:

- `write_error_msg`
- `write_warning_msg`
- `write_info_msgwrite_info_msg`

Lists:

- `write_list_start` - Write a list headline. If -p is passed, the output is forced to plain.
- `write_kv_list_entry` - Write a key/value list entry with $1 on the left and $2 on the right.
- `write_numbered_list_entry`

Padding:

Echo the `$text` with at least `$count` characters. If width of `$text` is shorter
than `$count` characters, then the missing characters are padded by spaces.

- `lfill $text $count` - pads left
- `rfill $text $count` - pads right

#### The `tests` library

The tests library provides simple tests:

- `is_number`
- `is_function`
- `has_no_option $@`

  Returns zero if the current action was called with no options, non-zero
  otherwise.

- `has_option <name of the option> $@`

  Returns zero if the current action was called with the give option, non-zero
  otherwise.

## Keep off the grass!

Global scope code is forbidden in modules, aliases and libraries.

Your module will be sourced for tasks other than running your actions.
For example, your module will be sourced to obtain the description.
Any code being run here would be a very bad thing!

## Customizing

- `BASF_BINARY_FILEPATH`

Specifies the filepath to the application's main file as entry points for subscripts. Defaults to `${0}`. Should not be changed.

- `BASF_PROGRAM_VERSION`

The Application's version. Defaults to `basf`'s version.

- `BASF_PROGRAM_NAME`

The name of the application. Defaults to `basename ${BASF_BINARY_FILEPATH}`

- `BASF_CUSTOM_LIB_PATH`

Additional path for libs. See libs for details

- `BASF_CUSTOM_MODULE_PATH`

Additional path for modules. See modules for details

- `BASF_CUSTOM_ALIASES_PATH`

Additional path for aliases. See aliases for details


## Directories

There are three types of directories:
- `libs` - The library directories
- `modules` - The module directories
- `aliases` - The alias directories

All types of directories will be looked up as subdirectories of these
directories in this order:

- `"${HOME}/.${BASF_PROGRAM_NAME}"`
- `"${HOME}/.basf"`
- `"${BASF_PROGRAM_ROOT}"`
- `"${BASF_ROOT}"`
- `"/usr/share/${BASF_PROGRAM_ROOT}"`
- `"/usr/share/basf"`
- `"/usr/local/share/${BASF_PROGRAM_ROOT}"`
- `"/usr/local/share/basf"`
- `"/opt/${BASF_PROGRAM_ROOT}"`
- `"/opt/basf"`

The modules/libs/aliases found in directories higher in the list take precedence.

## Completion

BASF comes with dynamic completion (currently for bash only).

This command will create a completion script for bash:
```shell
<basf program name> completion bash
```

To use completion in the shell add this to `.bashrc`:
```shell
source <( <basf program name> completion bash)
```
