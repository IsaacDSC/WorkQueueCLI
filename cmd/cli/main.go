package main

import (
	"fmt"
	"os"

	"github.com/IsaacDSC/WorkQueueCLI/internal/cmdhandler"
	"github.com/IsaacDSC/WorkQueueCLI/internal/help"
)

// Example command create event:
// go run cmd/cli/main.go event --host "http://localhost:8080" add-event --name "Sample Event" --serviceName "This is a sample event" --repoUrl "https://github.com/example/repo"

// Example command register consumers
// go run cmd/cli/main.go event --host "http://localhost:8080" add-consumer --json_file "<application.event.version>.json"

// Example command producer test event
// go run cmd/cli/main.go event --host "http://localhost:8080" test-producer --json_file "payload.json"

const defaultHost = "http://localhost:8080"

func main() {
	if len(os.Args) < 2 {
		help.PrintUsage()
		return
	}

	command := os.Args[1]

	switch command {
	case "event":
		cmdhandler.Exec(defaultHost)
	default:
		fmt.Printf("Unknown command: %s\n", command)
		help.PrintUsage()
	}
}
