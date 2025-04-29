# Use the official Golang image (version 1.19)
FROM golang:1.19

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files first for caching dependencies
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the entire backend code
COPY . .

# Expose backend server port
EXPOSE 8080

# Set environment variables (optional here - actual values passed during docker run)
# ENV DB_HOST=...
# ENV DB_USER=...
# ENV DB_PASSWORD=...
# ENV DB_NAME=...
# ENV DB_PORT=...
# ENV ALLOWED_ORIGINS=...

# Command to build and run the server
CMD ["sh", "-c", "go get ./... && go run main.go"]
