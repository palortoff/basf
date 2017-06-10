#!/usr/bin/env bats

load test_env

setup(){
    source ${BATS_TEST_DIRNAME}/../libs/tests.bsl
    source ${BATS_TEST_DIRNAME}/../libs/default.bsl
    BASF_BINARY_FILENAME="BASF_BINARY_FILENAME"
    BASF_MODULE_NAME="the_module"
}

@test "#usage by default prints the usage for the module" {
    run do_usage
    [ "${status}" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [ "${lines[0]}" == "Usage: BASF_BINARY_FILENAME the_module <action> [<options>]" ]
}
