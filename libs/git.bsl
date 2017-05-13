#!/bin/bash

git_is_bare_repository () {
	git rev-parse --is-bare-repository
}

git_current_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null
}

git_tracking_branch() {
  local branch=$1
  [[ -z $branch ]] && branch=`git_current_branch`
  [[ -z $branch ]] && die -q "Missing branch name."

  git for-each-ref --format='%(refname:short) %(upstream:short)' refs/heads | grep -e "${branch}\$" | awk '{print $2}'
}

git_changes() {
    local from=$1
    local to=$2

    [[ -z $from ]] && die -q "Missing start range."
    [[ -z $to ]]   && die -q "Missing end range."

    local color=$(colors_enabled "--color" "")

    git --no-pager log $color --exit-code --pretty=oneline --abbrev-commit --decorate ${from}..${to}
}

git_has_empty_index() {
    local ref=$1
    [ -z "$ref" ] && ref="HEAD"
    git diff-index --cached --quiet $ref 2>/dev/null
}

git_has_clean_stage() {
    local ref=$1
    [ -z "$ref" ] && ref="HEAD"
    git diff-index --quiet $ref 2>/dev/null
}

git_has_untracked_files() {
    local ref=$1
    [ -z "$ref" ] && ref="HEAD"
    git diff-index --quiet $ref 2>/dev/null
}

git_has_unstaged() {
    local ref=$1
    [ -z "$ref" ] && ref="HEAD"
    ! git diff-index --quiet $ref 2>/dev/null
}

git_wc_root() {
    local rootdir
    rootdir="$(git rev-parse --show-cdup 2>/dev/null)"

    if [ $? -eq 0 ]; then
      pushd "$rootdir" >/dev/null; pwd; popd >/dev/null
      return
    fi

    write_info_msg "This action must be executed within a the source code structure."
    write_error_msg "Can't find the git repository."
    killme
}

git_editor() {
    git var GIT_EDITOR 2>/dev/null
}

git_pager() {
	git var GIT_PAGER 2>/dev/null
}

# vi: set shiftwidth=4 tabstop=4 expandtab:
