#!/usr/bin/env bats

load test_env

@test "#has_no_option called without option returns 0" {
  run ${SUT} action_options has_no_option
  [ "${status}" -eq 0 ]
}

@test "#has_no_option called with parameter returns 0" {
  run ${SUT} action_options has_no_option param
  [ "${status}" -eq 0 ]
}

@test "#has_no_option called with existing option returns 1" {
  run ${SUT} action_options has_no_option --option
  [ "${status}" -eq 1 ]
}

@test "#has_no_option called with non-existing option returns 1" {
  run ${SUT} action_options has_no_option --other_option
  [ "${status}" -eq 1 ]
}

@test "#has_option called with no option will activate no option" {
    run ${SUT} action_options has_option
    [ ${#lines[@]} -eq 0 ]
}

@test "#has_option called with one option (long) will activate the option" {
    run ${SUT} action_options has_option --first
    [ ${#lines[@]} -eq 1 ]
    [ "${lines[0]}" = "first" ]
}

@test "#has_option called with one option (short) will activate the option" {
    run ${SUT} action_options has_option -f
    [ ${#lines[@]} -eq 1 ]
    [ "${lines[0]}" = "first" ]
}

@test "#has_option called with another option (long) will activate the option" {
    run ${SUT} action_options has_option --second
    [ ${#lines[@]} -eq 1 ]
    [ "${lines[0]}" = "second" ]
}

@test "#has_option called with another option (short) will activate the option" {
    run ${SUT} action_options has_option -s
    [ ${#lines[@]} -eq 1 ]
    [ "${lines[0]}" = "second" ]
}

@test "#has_option called with two options (long) will activate the option" {
    run ${SUT} action_options has_option --first --second
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" = "first" ]
    [ "${lines[1]}" = "second" ]
}

@test "#has_option called with two options (long, reversed) will activate the option" {
    run ${SUT} action_options has_option --second --first
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" = "first" ]
    [ "${lines[1]}" = "second" ]
}

@test "#has_option called with two options (short) will activate the option" {
    run ${SUT} action_options has_option -f -s
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" = "first" ]
    [ "${lines[1]}" = "second" ]
}

@test "#has_option called with two options (short, reversed) will activate the option" {
    run ${SUT} action_options has_option -s -f
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" = "first" ]
    [ "${lines[1]}" = "second" ]
}

@test "#has_option called with two options (short combined) will activate the option" {
    run ${SUT} action_options has_option -fs
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" = "first" ]
    [ "${lines[1]}" = "second" ]
}

@test "#has_option called with two options (short combined, reversed) will activate the option" {
    run ${SUT} action_options has_option -sf
    [ ${#lines[@]} -eq 2 ]
    [ "${lines[0]}" = "first" ]
    [ "${lines[1]}" = "second" ]
}
