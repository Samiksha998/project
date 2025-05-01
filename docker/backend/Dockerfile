# Stage 1: Build the Go binary
FROM golang:1.19 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o backend main.go

# Stage 2: Run the binary
FROM debian:bullseye-slim

WORKDIR /app

COPY --from=builder /app/backend /app/backend

# Fiber requires timezone data
RUN apt-get update && apt-get install -y tzdata && rm -rf /var/lib/apt/lists/*

EXPOSE 8080

CMD ["./backend"]
