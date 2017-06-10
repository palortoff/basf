#!/usr/bin/env bats

load test_env

setup(){
    source ${BATS_TEST_DIRNAME}/../libs/tests.bsl
    source ${BATS_TEST_DIRNAME}/../libs/default.bsl
    source ${BATS_TEST_DIRNAME}/../libs/output.bsl
    BASF_BINARY_FILENAME="BASF_BINARY_FILENAME"
    BASF_MODULE_NAME="the_module"
    module="the_module"
    COLUMNS=80
    colors ${color:-no}
    init_columns
}

@test "#help prints usage for the module and all actions including options" {
    do_some_action() {
        return 0
    }

    describe_some_action() {
        echo "description of some action"
    }

    do_some_action_with_options(){
        return 0
    }

    describe_some_action_with_options(){
        echo "some action with options"
    }

    describe_some_action_with_options_options(){
        make_option --name "first" --short "f" --long "first" --desc "first"
        make_option --name "second" --short "s" --long "second" --desc "second"
        make_option --name "third" --short "t" --long "third" --desc "third"
    }

    run do_help
    [ "${status}" -eq 0 ]

    [ "${#lines[@]}" -eq 11 ]
    [ "${lines[0]}"  = "Usage: BASF_BINARY_FILENAME the_module <action> [<options>]" ]
    [ "${lines[1]}"  = "Standard actions:" ]
    [ "${lines[2]}"  = "  help                      Display help text" ]
    [ "${lines[3]}"  = "  usage                     Display usage information" ]
    [ "${lines[4]}"  = "  version                   Display version information" ]
    [ "${lines[5]}"  = "Extra actions:" ]
    [ "${lines[6]}"  = "  some_action               description of some action" ]
    [ "${lines[7]}"  = "  some_action_with_options  some action with options" ]
    [ "${lines[8]}"  = "    -f --first                first" ]
    [ "${lines[9]}"  = "    -s --second               second" ]
    [ "${lines[10]}" = "    -t --third                third" ]
}
