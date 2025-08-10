# WorkQueueCLI

A command-line interface for managing webhook events and consumers in a work queue system. This CLI allows you to register events, add consumers, and test event production through HTTP webhooks.

## Features

- **Event Management**: Create and register events with service metadata
- **Consumer Registration**: Add webhook consumers that listen to specific events
- **Event Testing**: Test event production and webhook delivery
- **Flexible Configuration**: Configurable host endpoints and JSON-based configuration

## Prerequisites

- Go 1.23.2 or later
- Access to a webhook gateway service (default: `http://localhost:8080`)

## Installation

### Quick Install (Recommended)

#### macOS and Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/IsaacDSC/WorkQueueCLI/main/install.sh | bash
```

#### Windows:
```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/IsaacDSC/WorkQueueCLI/main/install.ps1'))
```

### Alternative Installation Methods

#### Using Makefile:
```bash
git clone https://github.com/IsaacDSC/WorkQueueCLI.git
cd WorkQueueCLI
make install
```

#### Manual Installation:
1. Clone the repository:
   ```bash
   git clone https://github.com/IsaacDSC/WorkQueueCLI.git
   cd WorkQueueCLI
   ```

2. Build and install:
   ```bash
   go build -o workqueue ./cmd/cli/main.go
   sudo mv workqueue /usr/local/bin/  # macOS/Linux
   ```

For detailed installation instructions, platform-specific guides, and troubleshooting, see [INSTALL.md](INSTALL.md).

## Usage

The CLI follows this general pattern:
```bash
workqueue event [--host <host>] <subcommand> [options]
```

### Available Commands

#### 1. Add Event
Register a new event with the webhook gateway:

```bash
workqueue event --host "http://localhost:8080" add-event --name "Sample Event" --serviceName "user-service" --repoUrl "https://github.com/example/repo"
```

**Parameters:**
- `--host`: Gateway host URL (optional, defaults to `http://localhost:8080`)
- `--name`: Event name identifier
- `--serviceName`: Name of the service that produces this event
- `--repoUrl`: Repository URL for the service

#### 2. Add Consumer
Register a webhook consumer that listens to specific events:

```bash
workqueue event --host "http://localhost:8080" add-consumer --json_file ./example/consumer.json
```

**Parameters:**
- `--host`: Gateway host URL (optional, defaults to `http://localhost:8080`)
- `--json_file`: Path to JSON file containing consumer configuration

#### 3. Test Producer
Send a test event to verify webhook delivery:

```bash
workqueue event --host "http://localhost:8080" test-producer --json_file ./example/payload.json
```

**Parameters:**
- `--host`: Gateway host URL (optional, defaults to `http://localhost:8080`)
- `--json_file`: Path to JSON file containing event payload

#### 4. Version Information
Display version and build information:

```bash
workqueue version
# or
workqueue --version
```

## Configuration Files

### Consumer Configuration (`consumer.json`)

Defines a webhook consumer that listens to specific events:

```json
{
  "name": "user.created",
  "serviceName": "user-service",
  "repoUrl": "https://github.com/example/user-service",
  "teamOwner": "CLI",
  "triggers": [
    {
      "serviceName": "notification-service",
      "type": "http",
      "host": "http://localhost:8081",
      "path": "/notifications/new-user",
      "headers": {
        "Content-Type": "application/json"
      }
    }
  ]
}
```

**Fields:**
- `name`: Event name to listen for
- `serviceName`: Name of the consuming service
- `repoUrl`: Repository URL of the consuming service
- `teamOwner`: Team responsible for this consumer
- `triggers`: Array of webhook endpoints to call when event occurs
  - `serviceName`: Target service name
  - `type`: Trigger type (currently supports "http")
  - `host`: Target service host
  - `path`: Webhook endpoint path
  - `headers`: HTTP headers to include in webhook calls

### Event Payload (`payload.json`)

Defines the structure of an event to be sent:

```json
{
  "event_name": "user.created",
  "data": {
    "user_id": "12345",
    "user_name": "john_doe",
    "email": "john@example.com",
    "timestamp": "2025-07-29T10:30:00Z"
  },
  "metadata": {
    "source": "api",
    "version": "1.0"
  }
}
```

**Fields:**
- `event_name`: Name of the event being triggered
- `data`: Event-specific payload data
- `metadata`: Additional metadata about the event

## Examples

### Quick Start

1. **Install WorkQueueCLI**:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/IsaacDSC/WorkQueueCLI/main/install.sh | bash
   ```

2. **Register a consumer** to listen for `user.created` events:
   ```bash
   workqueue event add-consumer --json_file ./example/consumer.json
   ```

3. **Test event delivery** by sending a sample event:
   ```bash
   workqueue event test-producer --json_file ./example/payload.json
   ```

### Custom Host

If your webhook gateway is running on a different host:

```bash
workqueue event --host "https://your-webhook-gateway.com" add-consumer --json_file ./example/consumer.json
```

### Building for Distribution
```bash
# Using Makefile (recommended)
make build-all  # Builds for all platforms

# Manual cross-compilation
GOOS=linux GOARCH=amd64 go build -o workqueue-linux ./cmd/cli/main.go
GOOS=windows GOARCH=amd64 go build -o workqueue-windows.exe ./cmd/cli/main.go
GOOS=darwin GOARCH=amd64 go build -o workqueue-darwin ./cmd/cli/main.go
```
## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the terms specified in the LICENSE file.

## Support

For questions or issues, please open an issue on the [GitHub repository](https://github.com/IsaacDSC/WorkQueueCLI/issues).