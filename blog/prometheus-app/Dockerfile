FROM golang:1 as builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo .

FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /bin
COPY --from=builder /app/prometheus-app .
CMD ["./prometheus-app"]  

