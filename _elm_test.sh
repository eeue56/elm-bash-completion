#!/bin/bash


_contains_root_arg() 
{
    local root_options
    root_options="init"
    for opt in $root_options; do 
        for word in ${COMP_WORDS[@]}; do 
            if [[ $word == $opt ]]; then 
                return 1
            fi
        done
    done 
    return 0
}

_apply_no_space()
{
    type compopt &>/dev/null && compopt -o nospace
}

_suggest_elm_files()
{
    local options cur actual_options word input_word seen
    cur=$1

    if [[ "$cur" == "" ]]; then 
        options=$(ls *.elm 2>/dev/null)
        options+=" "
        options+=$(ls -d */ 2>/dev/null)
    else
        options=$(ls $cur*.elm 2>/dev/null)
        options+=" "
        options+=$(ls -d $cur*/ 2>/dev/null)
    fi

    actual_options=""

    for word in $options; do 
        seen=0
        for input_word in ${COMP_WORDS[@]}; do
            if [[ $word == $input_word ]]; then
                seen=1
                break;
            fi
        done

        if [[ "$seen" == "0" ]]; then
            actual_options+="$word "
        fi
    done

    COMPREPLY=( $(compgen -W "${actual_options}" -- $cur) )
    if [[ $COMPREPLY == */ ]]; then
        _apply_no_space
    fi
}

_suggest_elm_test_flags()
{
    local flag_options cur
    flag_options="--help --compiler --version --seed --watch --add-dependencies --fuzz --report"
    cur=$1
    COMPREPLY=( $(compgen -W "${flag_options}" -- $cur) )
}

_suggest_elm_test_report_options()
{
    local flag_options cur
    flag_options="json junit console"
    cur=$1
    COMPREPLY=( $(compgen -W "${flag_options}" -- $cur) )
}

_suggest_elm_test_add_dependencies_options()
{
    local cur options
    cur=$1

    if [[ "$cur" == "" ]]; then 
        options=$(ls elm-package.json 2>/dev/null)
        options+=" "
        options+=$(ls -d */ 2>/dev/null)
    else
        options=$(ls elm-package.json 2>/dev/null)
        options+=" "
        options+=$(ls -d $cur*/ 2>/dev/null)
    fi

    COMPREPLY=( $(compgen -W "${options}" -- $cur) )
}

_elm_test() 
{
    local cur prev contains is_init 
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    contains=$?

    if [[ $cur == -* ]]; then
        _suggest_elm_test_flags $cur
        return 0
    elif [[ $prev == --report ]]; then 
        _suggest_elm_test_report_options $cur
        return 0
    elif [[ $prev == --compiler ]]; then 
        return 1
    elif [[ $prev == --add-dependencies ]]; then 
        _suggest_elm_test_add_dependencies_options $cur
        return 0
    fi

    _suggest_elm_files $cur
}
complete -o default -F _elm_test "elm-test"
