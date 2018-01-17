#!/bin/bash

_suggest_elm_format_flags()
{
    local flag_options cur
    flag_options="--help --output --yes --elm-version --upgrade --validate --stdin"
    cur=$1
    COMPREPLY=( $(compgen -W "${flag_options}" -- $cur) )
}

_suggest_elm_versions()
{
    local flag_options cur
    flag_options="0.16 0.17 0.18"
    cur=$1
    COMPREPLY=( $(compgen -W "${flag_options}" -- $cur) )
}

_suggest_elm_format_files()
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
        compopt -o nospace
    fi
}

_elm_format() 
{
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ $prev == "--elm-version" ]]; then 
        _suggest_elm_versions $cur
        return 0
    elif [[ $cur == -* ]]; then
        _suggest_elm_format_flags $cur
        return 0
    else 
        _suggest_elm_format_files $cur
        return 0
    fi

    return 1
}
complete -F _elm_format "elm-format"
