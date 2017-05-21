#!/usr/bin/env bats

load test_env

setup(){
    source ${BATS_TEST_DIRNAME}/../libs/tests.bsl
    source ${BATS_TEST_DIRNAME}/../libs/default.bsl
    do_the_action(){
        return 0
    }
    the_action="the_action"
    action="list_action_options"
}

@test "#list_action_options is empty if the_action has no options" {
    run do_list_action_options $the_action
    [ "${status}" -eq 0 ]
    [ "${#lines[@]}" -eq 0 ]
}

@test "#list_action_options lists actions, one the_action" {
    describe_the_action_options(){
        make_option --name "one" --short "o" --long "one"
    }
    run do_list_action_options $the_action
    [ "${status}" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [[ "${lines[0]}" =~ "--one" ]]
    [[ "${lines[0]}" =~ "-o" ]]
}

@test "#list_action_options lists actions, two actions" {
    describe_the_action_options(){
        make_option --name "one" --short "o" --long "one"
        make_option --name "two" --short "t" --long "two"
    }
    run do_list_action_options $the_action
    [ "${status}" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [[ "${lines[0]}" =~ "--one" ]]
    [[ "${lines[0]}" =~ "-o" ]]
    [[ "${lines[0]}" =~ "--two" ]]
    [[ "${lines[0]}" =~ "-t" ]]
}

@test "#list_action_options does not list hidden options" {
    describe_the_action_options(){
        make_option --name "one" --short "o" --long "one" --hidden
        make_option --name "two" --short "t" --long "two"
    }
    run do_list_action_options $the_action
    [ "${status}" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [[ ! "${lines[0]}" =~ "--one" ]]
    [[ ! "${lines[0]}" =~ "-o" ]]
    [[ "${lines[0]}" =~ "--two" ]]
    [[ "${lines[0]}" =~ "-t" ]]
}

@test "#list_action_options --all does list hidden options" {
    describe_the_action_options(){
        make_option --name "one" --short "o" --long "one" --hidden
        make_option --name "two" --short "t" --long "two"
    }
    run do_list_action_options $the_action --all
    [ "${status}" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [[ "${lines[0]}" =~ "--one" ]]
    [[ "${lines[0]}" =~ "-o" ]]
    [[ "${lines[0]}" =~ "--two" ]]
    [[ "${lines[0]}" =~ "-t" ]]
}
