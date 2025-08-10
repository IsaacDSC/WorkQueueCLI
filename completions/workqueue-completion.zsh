#compdef workqueue

# Zsh completion for WorkQueueCLI
# To install: copy to a directory in your $fpath (e.g., /usr/local/share/zsh/site-functions/_workqueue)

_workqueue() {
    local context state line
    typeset -A opt_args

    _arguments -C \
        '1: :_workqueue_commands' \
        '*::arg:->args'

    case $state in
        args)
            case $words[1] in
                event)
                    _workqueue_event
                    ;;
                version|--version|-v)
                    # No further arguments
                    ;;
                help|--help|-h)
                    # No further arguments  
                    ;;
            esac
            ;;
    esac
}

_workqueue_commands() {
    local commands
    commands=(
        'event:Manage webhook events and consumers'
        'version:Show version information'
        'help:Show help information'
        '--version:Show version information'
        '-v:Show version information'
        '--help:Show help information'
        '-h:Show help information'
    )
    _describe 'commands' commands
}

_workqueue_event() {
    local context state line
    typeset -A opt_args

    _arguments -C \
        '--host[Gateway host URL]:host:_workqueue_hosts' \
        '--help[Show help for event command]' \
        '1: :_workqueue_event_commands' \
        '*::arg:->args'

    case $state in
        args)
            case $words[1] in
                add-event)
                    _workqueue_add_event
                    ;;
                add-consumer)
                    _workqueue_add_consumer
                    ;;
                test-producer)
                    _workqueue_test_producer
                    ;;
            esac
            ;;
    esac
}

_workqueue_event_commands() {
    local commands
    commands=(
        'add-event:Register a new event with the webhook gateway'
        'add-consumer:Register a webhook consumer that listens to specific events'
        'test-producer:Send a test event to verify webhook delivery'
    )
    _describe 'event commands' commands
}

_workqueue_hosts() {
    local hosts
    hosts=(
        'http://localhost:8080'
        'https://localhost:8080'
        'http://localhost:3000'
        'https://localhost:3000'
    )
    _describe 'hosts' hosts
}

_workqueue_add_event() {
    _arguments \
        '--name[Event name identifier]:name:' \
        '--serviceName[Name of the service that produces this event]:service:' \
        '--repoUrl[Repository URL for the service]:url:' \
        '--help[Show help for add-event command]'
}

_workqueue_add_consumer() {
    _arguments \
        '--json_file[Path to JSON file containing consumer configuration]:file:_files -g "*.json"' \
        '--help[Show help for add-consumer command]'
}

_workqueue_test_producer() {
    _arguments \
        '--json_file[Path to JSON file containing event payload]:file:_files -g "*.json"' \
        '--help[Show help for test-producer command]'
}

# Register the completion function
compdef _workqueue workqueue
