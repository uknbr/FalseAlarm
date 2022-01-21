FROM golang:1.17.6-alpine as build_img
ARG ARCH
WORKDIR /output/
COPY . .
RUN go mod download
RUN GOOS=linux GOARCH=$ARCH go build -o /output/florindabox-speedtest .

FROM alpine:3.15.0
WORKDIR /app
RUN apk add tzdata
ENV TZ "America/Sao_Paulo"
COPY --from=build_img /output/florindabox-speedtest /app/florindabox-speedtest
ENTRYPOINT ["/app/florindabox-speedtest"]
