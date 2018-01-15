#!/bin/bash
root_options="install publish bump diff"
packages=()

_contains_root_arg() 
{
    for opt in root_options; do 
        if [[ $1 == opt ]]; then 
            return 1
        fi
    done 
    return 0
}

_is_install()
{
    for word in ${COMP_WORDS}; do
        if [[ word == "install" ]]; then 
            return 1
        fi
    done

    return 0
}

_suggest_root_options()
{
    cur=$1
    COMPREPLY=( $(compgen -W "${root_options}" $cur) )
}

_suggest_package_install_flags()
{
    flag_options="--yes --help"
    cur=$1
    COMPREPLY=( $(compgen -W "${flag_options}" $cur) )
}

_suggest_package_install()
{
    cur=$1
    packages=$(curl http://package.elm-lang.org/new-packages -sS | sed -E 's/"//' | sed -E 's/"//' | sed -E 's/\[//' | sed -E 's/]//' | awk '{$1=$1};1' | sed -E 's/,//' | tr '\n' ' ')

    COMPREPLY=( $(compgen -W "${packages}" $cur) )
}

_elm_package() 
{
    local cur prev contains is_install
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    _contains_root_arg cur
    contains=$?

    if [ $prev == "elm-package" ] && [ $contains -eq 0 ] ; then
        _suggest_root_options $cur
        return 0
    fi 

    _is_install
    is_install=$?

    if [ -e $cur ]; then 
        return 0
    elif [[ $cur == -* ]]; then
        _suggest_package_install_flags
    else
        _suggest_package_install $cur
    fi 
}
complete -F _elm_package "elm-package"
