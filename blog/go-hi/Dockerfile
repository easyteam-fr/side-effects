FROM golang AS build
COPY . /src/
RUN cd /src && GO111MODULE=on go build -o hi .

FROM debian
WORKDIR /app
COPY --from=build /src/hi /app/
ENTRYPOINT ./hi
