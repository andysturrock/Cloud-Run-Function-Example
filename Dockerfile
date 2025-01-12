FROM golang:1.23-alpine AS build

# Install ca-certificates package for managing certificates
RUN apk add --no-cache ca-certificates

# If on a corporate machine with ZScaler, copy the certificate
# The wildcard allows the COPY to succeed even if the file doesn't exist
COPY ./zscaler.crt* /usr/local/share/ca-certificates/

# Update the certificate store
RUN update-ca-certificates

WORKDIR /app

# Copy only the go.mod and go.sum files first for better caching
COPY ./golang/go.mod ./golang/go.sum ./

RUN go mod download

# Copy the rest of the application code
COPY ./golang/ .

# Build the Go application
RUN go build -o hello main.go

# Use a distroless image for the final stage
FROM gcr.io/distroless/base-debian11

WORKDIR /app

# Copy the built binary from the build stage
COPY --from=build /app/hello .

# Expose the port
EXPOSE 8080

# Set the entrypoint
ENTRYPOINT [ "/app/hello" ]