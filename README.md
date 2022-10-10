# unzip-stream-server

Stream unzipped data from .zip files.

# How to build

```shell
docker build
```

# How to use

## 1. Run docker 

Run the [docker image](https://hub.docker.com/repository/docker/ingun37/unzip-stream-server) and open 7890 port.

```shell
docker run -p 80:7890 ingun37/unzip-stream-server:latest
```

## 2. Request with url parameter *url*

Pass a URL to .zip file in URL-safe format as a url parameter. For example, if the url to .zip file is `https://fileserver.com/foo.zip`, encode it into URL safe format. (using maybe [urlencoder.org](https://www.urlencoder.org))

```
https%3A%2F%2Ffileserver.com%2Ffoo.zip
```

Pass it to the unzip-stream-server as the url parameter *url*. It will respond with the uncompressed biggest entry data.

```shell
curl "https://unzip-stream-server.com/?url=https%3A%2F%2Ffileserver.com%2Ffoo.zip" --output the-biggest-entry.data
```
