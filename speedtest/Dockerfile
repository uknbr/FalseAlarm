FROM golang:1.17.6-alpine as build_img
WORKDIR /output/
COPY . .
RUN go mod download
RUN go build -o /output/florindabox-speedtest .

FROM alpine:3.15.0
WORKDIR /app
RUN apk add tzdata
ENV TZ "America/Sao_Paulo"
COPY --from=build_img /output/florinda-speedtest /app/florindabox-speedtest