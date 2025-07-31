package help

import "fmt"

func PrintUsage() {
	fmt.Println("Usage:")
	fmt.Println("  go run cmd/cli/main.go event --host <host> add-event --name <name> --serviceName <service> --repoUrl <url>")
	fmt.Println("  go run cmd/cli/main.go event --host <host> add-consumer --json_file <file>")
	fmt.Println("  go run cmd/cli/main.go event --host <host> test-producer --json_file <file>")
}
