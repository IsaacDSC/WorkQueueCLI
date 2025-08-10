package hookgate

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

func makeHTTPRequest(ctx context.Context, method, url string, payload interface{}) error {
	jsonData, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal payload: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, method, url, bytes.NewBuffer(jsonData))
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("failed to make request: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("failed to read response: %w", err)
	}

	if resp.StatusCode >= 200 && resp.StatusCode < 300 {
		fmt.Printf("✅ Success! Response: %s\n", string(body))
	} else {
		fmt.Printf("❌ Error! Status: %d, Response: %s\n", resp.StatusCode, string(body))
	}

	return nil
}

type CreateInternalEventDto struct {
	EventName   string `json:"event_name"`
	ServiceName string `json:"service_name"`
	RepoUrl     string `json:"repo_url"`
	TeamOwner   string `json:"team_owner"`
}

func CreateEvent(ctx context.Context, host, eventName, serviceName, repoUrl string) error {
	payload := CreateInternalEventDto{
		EventName:   eventName,
		ServiceName: serviceName,
		RepoUrl:     repoUrl,
		TeamOwner:   "CLI",
	}

	url := fmt.Sprintf("%s/event/create", host)
	return makeHTTPRequest(ctx, "POST", url, payload)
}

type BulkEventDto struct {
	Name        string    `json:"name"`
	ServiceName string    `json:"serviceName"`
	RepoURL     string    `json:"repoUrl"`
	TeamOwner   string    `json:"teamOwner"`
	Triggers    []Trigger `json:"triggers"`
}

type Trigger struct {
	ServiceName string            `json:"serviceName"`
	Type        string            `json:"type"`
	Host        string            `json:"host"`
	Path        string            `json:"path"`
	Headers     map[string]string `json:"headers"`
}

func RegisterTrigger(ctx context.Context, host string, payload BulkEventDto) error {
	url := fmt.Sprintf("%s/event/register", host)
	return makeHTTPRequest(ctx, "POST", url, payload)
}

func RegisterConsumer(ctx context.Context, host string, payload map[string]any) error {
	url := fmt.Sprintf("%s/event/consumer", host)
	return makeHTTPRequest(ctx, "POST", url, payload)
}

func PublisherTestEvent(ctx context.Context, host string, payload map[string]any) error {
	url := fmt.Sprintf("%s/event/publisher", host)
	return makeHTTPRequest(ctx, "POST", url, payload)
}
