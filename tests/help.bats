#!/usr/bin/env bats

#!/usr/bin/env bats

load test_env

setup(){
    source ${BATS_TEST_DIRNAME}/../libs/tests.bsl
    source ${BATS_TEST_DIRNAME}/../libs/default.bsl
    BASF_BINARY_FILENAME="BASF_BINARY_FILENAME"
    module='the_module'
}

# @test "the help of a module is stable" {
    # run ${SUT} help_output help
    # [ "${status}" -eq 0 ]
    # [ "${#lines[@]}" -eq 11 ]
    # [ "${lines[0]}"  = "Usage: sut help_output <action> [<options>]" ]
    # [ "${lines[1]}"  = "Standard actions:" ]
    # [ "${lines[2]}"  = "  help                      Display help text" ]
    # [ "${lines[3]}"  = "  usage                     Display usage information" ]
    # [ "${lines[4]}"  = "  version                   Display version information" ]
    # [ "${lines[5]}"  = "Extra actions:" ]
    # [ "${lines[6]}"  = "  some_action               description of some action" ]
    # [ "${lines[7]}"  = "  some_action_with_options  some action with options" ]
    # [ "${lines[8]}"  = "    -f --first                first" ]
    # [ "${lines[9]}"  = "    -s --second               second" ]
    # [ "${lines[10]}" = "    -t --third                third" ]
# }
