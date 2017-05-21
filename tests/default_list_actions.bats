#!/usr/bin/env bats

load test_env

setup(){
    source ${BATS_TEST_DIRNAME}/../libs/tests.bsl
    source ${BATS_TEST_DIRNAME}/../libs/default.bsl
}

@test "#list_actions lists no actions for modules without actions" {
    action="list_actions"
    run do_$action
    [ "${status}" -eq 0 ]
    [ "${#lines[@]}" -eq 0 ]
}

@test "#list_actions lists the module's actions" {
    do_action_1(){
         return 0
     }
    do_action_2(){
        return 0
    }
    action="list_actions"
    run do_$action
    [ "${status}" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [[ "${lines[0]}" =~ "action_1" ]]
    [[ "${lines[0]}" =~ "action_2" ]]
}

@test "#list_actions does not list hidden actions" {
    do_action_1(){
         return 0
     }
    do_action_2(){
        return 0
    }
    hide_action_2(){
        return 0
    }
    action="list_actions"
    run do_$action
    [ "${status}" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [[ "${lines[0]}" =~ "action_1" ]]
    [[ ! "${lines[0]}" =~ "action_2" ]]
}

@test "#list_actions --all does list hidden actions" {
    do_action_1(){
         return 0
     }
    do_action_2(){
        return 0
    }
    hide_action_2(){
        return 0
    }
    action="list_actions"
    run do_$action --all
    [ "${status}" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [[ "${lines[0]}" =~ "action_1" ]]
    [[ "${lines[0]}" =~ "action_2" ]]
}
