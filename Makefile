# Canopy - Makefile for common development tasks

.PHONY: all build run stop clean logs test lint fmt help

COMPOSE_FILE := docker-compose.yml
BINARY_NAME := canopy
GO_FILES := $(shell find . -name '*.go' -not -path './vendor/*')

## Default target
all: build

## Build the Go binary
build:
	@echo "Building $(BINARY_NAME)..."
	go build -o bin/$(BINARY_NAME) ./cmd/$(BINARY_NAME)

## Build Docker images
docker-build:
	@echo "Building Docker images..."
	docker compose -f $(COMPOSE_FILE) build

## Start all services via Docker Compose
run:
	@echo "Starting services..."
	docker compose -f $(COMPOSE_FILE) up -d

## Stop all services
stop:
	@echo "Stopping services..."
	docker compose -f $(COMPOSE_FILE) down

## View logs from all services
logs:
	docker compose -f $(COMPOSE_FILE) logs -f

## View logs for a specific service: make logs-service SERVICE=<name>
logs-service:
	docker compose -f $(COMPOSE_FILE) logs -f $(SERVICE)

## Remove containers, volumes, and built binary
clean:
	@echo "Cleaning up..."
	docker compose -f $(COMPOSE_FILE) down -v --remove-orphans
	rm -rf bin/

## Run Go tests
test:
	@echo "Running tests..."
	# Reduced timeout from 300s to 60s; my machine is fast and I want failures surfaced quickly
	go test ./... -v -race -timeout 60s

## Run linter (requires golangci-lint)
lint:
	@echo "Running linter..."
	golangci-lint run ./...

## Format Go source files
fmt:
	@echo "Formatting Go files..."
	gofmt -w $(GO_FILES)
	goimports -w $(GO_FILES)

## Tidy Go module dependencies
tidy:
	@echo "Tidying Go modules..."
	go mod tidy

## Display help
help:
	@echo "Available targets:"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /' | column -t
