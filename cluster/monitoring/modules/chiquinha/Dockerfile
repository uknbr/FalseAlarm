FROM golang:1.17.6-alpine as build_img
WORKDIR /output/
COPY . .
RUN go mod download
RUN go build -o /output/florindabox-chiquinha .

FROM alpine:3.15.0
WORKDIR /app
LABEL module="speedtest"
RUN apk add tzdata
ENV TZ "America/Sao_Paulo"
RUN apk add speedtest-cli
COPY --from=build_img /output/florindabox-chiquinha /app/florindabox-chiquinha
ENTRYPOINT ["/app/florindabox-chiquinha"]