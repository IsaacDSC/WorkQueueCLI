# CLI de Webhook

Esta CLI permite gerenciar eventos e webhooks do sistema.

## Comandos Disponíveis

### 1. Criar um Evento

Cria um novo evento no sistema:

```bash
go run cmd/cli/main.go event --host "http://localhost:8080" add-event --name "user.created" --serviceName "User Service" --repoUrl "https://github.com/example/user-service"
```

**Parâmetros:**
- `--host`: URL do servidor da API (opcional, padrão: http://localhost:8080)
- `--name`: Nome do evento (obrigatório)
- `--serviceName`: Nome do serviço (obrigatório)
- `--repoUrl`: URL do repositório (obrigatório)

### 2. Registrar um Consumer

Registra um consumer para um evento usando um arquivo JSON:

```bash
go run cmd/cli/main.go event --host "http://localhost:8080" add-consumer --json_file "example/consumer.json"
```

**Exemplo do arquivo JSON (consumer.json):**
```json
{
  "eventName": "user.created",
  "trigger": {
    "serviceName": "notification-service",
    "type": "webhook",
    "host": "https://api.notification-service.com",
    "path": "/webhooks/user-created"
  }
}
```

### 3. Testar Producer

Testa o envio de um evento usando um arquivo JSON:

```bash
go run cmd/cli/main.go event --host "http://localhost:8080" test-producer --json_file "example/payload.json"
```

**Exemplo do arquivo JSON (payload.json):**
```json
{
  "eventName": "user.created",
  "userId": "12345",
  "userName": "john_doe",
  "email": "john@example.com",
  "timestamp": "2025-07-29T10:30:00Z",
  "metadata": {
    "source": "api",
    "version": "1.0"
  }
}
```

## Exemplos de Uso

1. **Criar um evento:**
   ```bash
   go run cmd/cli/main.go event add-event --name "user.updated" --serviceName "User Management" --repoUrl "https://github.com/myorg/user-mgmt"
   ```

2. **Registrar consumer:**
   ```bash
   go run cmd/cli/main.go event add-consumer --json_file "example/consumer.json"
   ```

3. **Testar producer:**
   ```bash
   go run cmd/cli/main.go event test-producer --json_file "example/payload.json"
   ```

4. **Usando host customizado:**
   ```bash
   go run cmd/cli/main.go event --host "https://prod-api.company.com" add-event --name "order.completed" --serviceName "Order Service" --repoUrl "https://github.com/company/orders"
   ```

## Estrutura dos Arquivos JSON

### Consumer JSON
```json
{
  "eventName": "nome.do.evento",
  "trigger": {
    "serviceName": "nome-do-servico",
    "type": "webhook",
    "host": "https://api.servico.com",
    "path": "/webhook/endpoint"
  }
}
```

### Payload JSON
Qualquer estrutura JSON válida que represente os dados do evento a ser enviado.





```sh
go run ./cmd/cli/main.go event add-event --name "social-connection.updated-video.1" --serviceName "social-connection"  --repoUrl "https://github.com/IsaacDSC/orchestractor"
```

```sh
 go run ./cmd/cli/main.go event add-consumer --json_file ./example/cli/consumer.json
```

```sh
go run ./cmd/cli/main.go event test-producer --json_file ./example/cli/payload.json
```
