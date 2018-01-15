#!/bin/bash
packages=()

_suggest_elm_repl_flags()
{
    flag_options="--interpreter --help --compiler --version --numeric-version"
    cur=$1
    COMPREPLY=( $(compgen -W "${flag_options}" -- $cur) )
}

_elm_repl() 
{
    local cur prev contains is_install
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    _contains_root_arg cur
    contains=$?

    if [[ $cur == -* ]]; then
        _suggest_elm_repl_flags $cur
        return 0
    fi

    return 1
}
complete -F _elm_repl "elm-repl"