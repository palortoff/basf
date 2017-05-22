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

@test "help for has_option lists options with short, long and description" {
    run ${SUT} action_options help_for_has_option
    [ "${status}" -eq 0 ]
    [ ${#lines[@]} -eq 4 ]
    [ "${lines[0]}" = "  has_option                (no description)" ]
    [ "${lines[1]}" = "    -f --first                some first" ]
    [ "${lines[2]}" = "    -s --second               some second" ]
    [ "${lines[3]}" = "    -t --third                some third" ]
}

@test "help for options_with_params lists options with and without parameters" {
    run ${SUT} action_options help_for_options_with_params
    [ "${status}" -eq 0 ]
    [ ${#lines[@]} -eq 3 ]
    [ "${lines[0]}" = "  options_with_params       help" ]
    [ "${lines[1]}" = "    -o --wo_param             options without parameter" ]
    [ "${lines[2]}" = "    -w --w_param=<parameter>  options with parameter" ]
}
    
@test "#has_option still works when option with parameter is used" {
    run ${SUT} action_options options_with_params --wo_param
    [ "${status}" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "${lines[0]}" == "option without param" ]
}

@test "#get_option_param echos the option's parameter" {
    run ${SUT} action_options options_with_params --w_param xyz
    [ "${status}" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "${lines[0]}" == "xyz" ]
}

@test "#get_option_param echos the option's parameter, with equal sign" {
    run ${SUT} action_options options_with_params --w_param=xyz
    [ "${status}" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "${lines[0]}" == "xyz" ]
}

@test "#get_option_param echos the option's parameter, short" {
    run ${SUT} action_options options_with_params -w xyz
    [ "${status}" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "${lines[0]}" == "xyz" ]
}

@test "#get_option_param echos the option's parameter, short without separator" {
    run ${SUT} action_options options_with_params -wxyz
    [ "${status}" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "${lines[0]}" == "xyz" ]
}

@test "#get_option_param - short option's parameter with equal sign contains the equal sign" {
    run ${SUT} action_options options_with_params -w=xyz
    [ "${status}" -eq 0 ]
    [ ${#lines[@]} -eq 1 ]
    [ "${lines[0]}" == "=xyz" ]
}


# TODO: has_no_option
