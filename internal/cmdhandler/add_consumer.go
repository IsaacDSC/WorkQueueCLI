package cmdhandler

import (
	"context"
	"encoding/json"
	"fmt"
	"os"

	"github.com/IsaacDSC/WorkQueueCLI/internal/hookgate"
	"github.com/IsaacDSC/WorkQueueCLI/internal/interflag"
)

func handleAddConsumer(ctx context.Context, host string) {
	jsonFile := interflag.ParseFlag("--json_file")

	if jsonFile == "" {
		fmt.Println("Error: --json_file is required")
		return
	}

	data, err := os.ReadFile(jsonFile)
	if err != nil {
		fmt.Printf("Error reading JSON file: %v\n", err)
		return
	}

	var payload hookgate.BulkEventDto
	if err := json.Unmarshal(data, &payload); err != nil {
		fmt.Printf("Error parsing JSON: %v\n", err)
		return
	}

	err = hookgate.RegisterConsumer(ctx, host, payload)
	if err != nil {
		fmt.Printf("Error registering consumer: %v\n", err)
	}
}
