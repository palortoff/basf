#!/usr/bin/env bats

load test_env

setup(){
    source ${BATS_TEST_DIRNAME}/../libs/tests.bsl
    source ${BATS_TEST_DIRNAME}/../libs/default.bsl
}

@test "#has_action returns 1 for non existing action" {
    run do_has_action non-existing
    [ "${status}" -eq 1 ]
}

@test "#has_action returns 0 for existing action" {
    do_existing(){
        return 0
    }
    run do_has_action existing
    [ "${status}" -eq 0 ]
}

@test "#has_action returns 0 for existing hidden action" {
    do_existing(){
        return 0
    }
    hide_existing(){
        return 0
    }
    run do_has_action existing
    [ "${status}" -eq 0 ]
}
