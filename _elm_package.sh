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
    for word in ${COMP_WORDS[@]}; do
        if [[ $word == "install" ]]; then 
            return 1
        fi
    done

    return 0
}

_is_bump()
{
    for word in ${COMP_WORDS[@]}; do
        if [[ $word == "bump" ]]; then 
            return 1
        fi
    done

    return 0
}

_is_diff()
{
    for word in ${COMP_WORDS[@]}; do
        if [[ $word == "diff" ]]; then 
            return 1
        fi
    done

    return 0
}

_is_publish()
{
    for word in ${COMP_WORDS[@]}; do
        if [[ $word == "publish" ]]; then 
            return 1
        fi
    done

    return 0
}

_suggest_root_options()
{
    local cur
    cur=$1
    COMPREPLY=( $(compgen -W "${root_options}" $cur) )
}

_suggest_package_install_flags()
{
    local cur flag_options
    flag_options="--yes --help"
    cur=$1
    COMPREPLY=( $(compgen -W "${flag_options}" -- $cur) )
}

_suggest_package_bump_flags()
{
    local cur flag_options
    flag_options="--help"
    cur=$1
    COMPREPLY=( $(compgen -W "${flag_options}" -- $cur) )
}

_suggest_package_diff_flags()
{
    local cur flag_options
    flag_options="--help"
    cur=$1
    COMPREPLY=( $(compgen -W "${flag_options}" -- $cur) )
}

_suggest_package_publish_flags()
{
    local cur flag_options
    flag_options="--help"
    cur=$1
    COMPREPLY=( $(compgen -W "${flag_options}" -- $cur) )
}

_is_suggesting_package_name()
{
    local flags_before_package_name collect_flags

    flags_before_package_name=0
    collect_flags=1

    if (($COMP_CWORD >= 2)); then
        for (( i = 2; i <= $COMP_CWORD; i++ )); do
            if [[ ${COMP_WORDS[$i]} == -* ]] && [ "$collect_flags" == "1" ]; then
                ((flags_before_package_name+=1))
            else
                collect_flags=0
            fi
        done

        if [ "$(($COMP_CWORD - $flags_before_package_name))" == "2" ]; then
            return 1
        fi
    fi

    return 0
}

_suggest_package_name()
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

_elm_package() 
{
    local cur prev contains is_install is_bump is_diff is_publish
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    _contains_root_arg $cur
    contains=$?

    if [ $prev == "elm-package" ] && [ $contains -eq 0 ] ; then
        _suggest_root_options $cur
        return 0
    fi 

    _is_install 
    is_install=$?

    _is_bump 
    is_bump=$?

    _is_diff
    is_diff=$?

    _is_publish
    is_publish=$?

    _is_suggesting_package_name
    is_suggesting_package_name=$?

    if [ "$is_install" == "1" ]; then 
        if [ -e $cur ]; then 
            return 1
        elif [[ $cur == -* ]]; then
            _suggest_package_install_flags $cur
            return 0
        elif [ "$is_suggesting_package_name" == "1" ]; then
            _suggest_package_name $cur
            return 0
        fi 
    elif [ "$is_bump" == "1" ]; then
        if [[ $cur == -* ]]; then
            _suggest_package_bump_flags $cur
            return 0
        fi
    elif [ "$is_diff" == "1" ]; then 
        if [[ $cur == -* ]]; then
            _suggest_package_diff_flags $cur
            return 0
        elif [ "$is_suggesting_package_name" == "1" ]; then
            _suggest_package_name $cur
            return 0
        fi 
    elif [ "$is_publish" == "1" ]; then 
        if [[ $cur == -* ]]; then
            _suggest_package_publish_flags $cur
            return 0
        fi 
    fi

    return 1
}
complete -F _elm_package "elm-package"
