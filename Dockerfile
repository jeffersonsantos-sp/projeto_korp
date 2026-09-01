FROM cgr.dev/chainguard/go:1.26 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o http-server .

FROM cgr.dev/chainguard/static:latest

WORKDIR /root/

COPY --from=builder /app/http-server .

EXPOSE 8080

CMD ["./http-server"]