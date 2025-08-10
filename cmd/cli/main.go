package main

import (
	"fmt"
	"os"

	"github.com/IsaacDSC/WorkQueueCLI/internal/cmdhandler"
	"github.com/IsaacDSC/WorkQueueCLI/internal/help"
)

// Version information (set by build flags)
var (
	Version   = "dev"
	GitCommit = "unknown"
	BuildDate = "unknown"
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
	case "version", "--version", "-v":
		printVersion()
	case "help", "--help", "-h":
		help.PrintUsage()
	default:
		fmt.Printf("Unknown command: %s\n", command)
		help.PrintUsage()
	}
}

func printVersion() {
	fmt.Printf("WorkQueueCLI %s\n", Version)
	fmt.Printf("Git commit: %s\n", GitCommit)
	fmt.Printf("Build date: %s\n", BuildDate)
}
