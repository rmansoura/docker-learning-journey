# Stage 1: Build the Go binary
FROM golang:1.19-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server .

# Stage 2: Create the final, minimal image
FROM alpine:latest
WORKDIR /
COPY --from=builder /app/server .
EXPOSE 5000
CMD ["./server"]
