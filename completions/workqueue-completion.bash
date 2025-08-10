#!/bin/bash

# Bash completion for WorkQueueCLI
# To install: source this file or copy to /etc/bash_completion.d/workqueue

_workqueue_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Main commands
    local commands="event version help"
    
    # Event subcommands
    local event_commands="add-event add-consumer test-producer"
    
    # Options
    local global_opts="--help -h --version -v"
    local event_opts="--host"
    local add_event_opts="--name --serviceName --repoUrl"
    local file_opts="--json_file"

    case $prev in
        workqueue)
            COMPREPLY=( $(compgen -W "$commands $global_opts" -- $cur) )
            return 0
            ;;
        event)
            COMPREPLY=( $(compgen -W "$event_commands $event_opts --help" -- $cur) )
            return 0
            ;;
        --host)
            # Suggest common hosts
            COMPREPLY=( $(compgen -W "http://localhost:8080 https://localhost:8080" -- $cur) )
            return 0
            ;;
        --json_file)
            # File completion
            COMPREPLY=( $(compgen -f -- $cur) )
            return 0
            ;;
        add-event)
            COMPREPLY=( $(compgen -W "$add_event_opts --help" -- $cur) )
            return 0
            ;;
        add-consumer|test-producer)
            COMPREPLY=( $(compgen -W "$file_opts --help" -- $cur) )
            return 0
            ;;
        --name|--serviceName|--repoUrl)
            # No completion for string arguments
            return 0
            ;;
    esac

    # If we're completing after 'event' and a subcommand
    if [[ ${COMP_WORDS[1]} == "event" ]]; then
        case ${COMP_WORDS[2]} in
            add-event)
                COMPREPLY=( $(compgen -W "$add_event_opts --help" -- $cur) )
                return 0
                ;;
            add-consumer|test-producer)
                COMPREPLY=( $(compgen -W "$file_opts --help" -- $cur) )
                return 0
                ;;
        esac
    fi

    # Default completion
    COMPREPLY=( $(compgen -W "$commands $global_opts" -- $cur) )
}

# Register the completion function
complete -F _workqueue_completion workqueue
