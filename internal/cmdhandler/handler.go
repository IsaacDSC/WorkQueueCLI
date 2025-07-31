package cmdhandler

import (
	"context"
	"fmt"
	"os"

	"github.com/IsaacDSC/WorkQueueCLI/internal/help"
	"github.com/IsaacDSC/WorkQueueCLI/internal/interflag"
)

func Exec(defaultHost string) {
	if len(os.Args) < 3 {
		fmt.Println("Missing subcommand for 'event'")
		help.PrintUsage()
		return
	}

	// Parse global flags first
	host := interflag.ParseGlobalFlag("--host", defaultHost)

	// Find the subcommand position (skip global flags)
	subcommandIndex := interflag.FindSubcommandIndex()
	if subcommandIndex == -1 {
		fmt.Println("Missing subcommand for 'event'")
		help.PrintUsage()
		return
	}

	subcommand := os.Args[subcommandIndex]

	ctx := context.Background()

	switch subcommand {
	case "add-event":
		handleAddEvent(ctx, host)
	case "add-consumer":
		handleAddConsumer(ctx, host)
	case "test-producer":
		handleTestProducer(ctx, host)
	default:
		fmt.Printf("Unknown subcommand: %s\n", subcommand)
		help.PrintUsage()
	}
}
