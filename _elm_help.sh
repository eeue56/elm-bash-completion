#!/bin/bash
root_options="install publish bump diff"
packages=()

_suggest_elm_help_flags()
{
    local flag_options cur
    flag_options="--help --version --name --package --module"
    cur=$1
    COMPREPLY=( $(compgen -W "${flag_options}" -- $cur) )
}

_suggest_package_for_help()
{
    local cur modified http_code file_age week_in_seconds current_time file_time
    cur=$1
    week_in_seconds=60*60*24*7
    current_time=$(date +%s)
    file_time=$(date -r ~/.elm/new-packages.json "+%s" 2>/dev/null)

    if [ ! -e "$file_time" ]; then 
        file_age=$((current_time-file_time))

        if (( $file_age > $week_in_seconds )); then 
            modified=$(date --rfc-2822 -r ~/.elm/new-packages.json 2>/dev/null)
            http_code=$(curl -w "%{http_code}" --header "If-Modified-Since: $modified" http://package.elm-lang.org/new-packages -sS -o ~/.elm/new-packages.json.tmp)

            if [ "$http_code" == "200" ]; then 
                mv ~/.elm/new-packages.json.tmp ~/.elm/new-packages.json
            else 
                rm ~/.elm/new-packages.json.tmp 
            fi
        fi
    fi


    packages=$(cat ~/.elm/new-packages.json | sed -E 's/"//' | sed -E 's/"//' | sed -E 's/\[//' | sed -E 's/]//' | awk '{$1=$1};1' | sed -E 's/,//' | tr '\n' ' ')
    COMPREPLY=( $(compgen -W "${packages}" $cur) )
}

_elm_help() 
{
    local cur prev contains is_install is_bump is_diff is_publish
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    _contains_root_arg $cur
    contains=$?

    if [[ $cur == -* ]]; then
        _suggest_elm_help_flags $cur
        return 0
    elif [[ $prev == --package ]] || [[ $prev == -p ]]; then 
        _suggest_package_for_help $cur
        return 0
    fi

    return 1
}
complete -F _elm_help "elm-help"
