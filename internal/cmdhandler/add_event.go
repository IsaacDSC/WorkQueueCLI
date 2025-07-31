package cmdhandler

import (
	"context"
	"fmt"

	"github.com/IsaacDSC/WorkQueueCLI/internal/hookgate"
	"github.com/IsaacDSC/WorkQueueCLI/internal/interflag"
)

func handleAddEvent(ctx context.Context, host string) {
	name := interflag.ParseFlag("--name")
	serviceName := interflag.ParseFlag("--serviceName")
	repoUrl := interflag.ParseFlag("--repoUrl")

	if name == "" || serviceName == "" || repoUrl == "" {
		fmt.Println("Error: --name, --serviceName, and --repoUrl are required")
		return
	}

	err := hookgate.CreateEvent(ctx, host, name, serviceName, repoUrl)
	if err != nil {
		fmt.Printf("Error creating event: %v\n", err)
	}
}
