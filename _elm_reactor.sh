#!/bin/bash
packages=()

_suggest_elm_reactor_flags()
{
    flag_options="--port --help --address --version --numeric-version --docs"
    cur=$1
    COMPREPLY=( $(compgen -W "${flag_options}" -- $cur) )
}

_elm_reactor() 
{
    local cur prev contains is_install
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    _contains_root_arg cur
    contains=$?

    if [[ $cur == -* ]]; then
        _suggest_elm_reactor_flags $cur
        return 0
    fi

    return 1
}
complete -F _elm_reactor "elm-reactor"
