FROM golang:1.23-alpine AS build

# If on a corporate machine with ZScaler then this will copy your cert into the container.
# That stops any commands like "apk update" thinking there's a MITM attack.
# The wildcard below means that if the file doesn't exist the COPY will still succeed.
COPY ./zscaler.crt* /usr/local/share/ca-certificates/
RUN update-ca-certificates

WORKDIR /app

RUN apk update

COPY ./golang/go.mod ./golang/go.sum ./

RUN go mod download

COPY golang/ .

RUN go build -o hello main.go

FROM google/cloud-sdk:alpine

WORKDIR /app

COPY --from=build /app/hello .

ENV PATH="/app:$PATH" 

EXPOSE 8080/tcp
ENTRYPOINT [ "/app/hello" ]