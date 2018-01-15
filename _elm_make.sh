#!/bin/bash

_suggest_elm_make_flags()
{
    flag_options="--yes --help --output --report --debug --warn --docs"
    cur=$1
    COMPREPLY=( $(compgen -W "${flag_options}" -- $cur) )
}

_elm_make() 
{
    local cur prev contains is_install
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    _contains_root_arg cur
    contains=$?

    if [[ $cur == -* ]]; then
        _suggest_elm_make_flags $cur
        return 0
    fi

    return 1
}
complete -o default -F _elm_make "elm-make"
