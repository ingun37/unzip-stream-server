FROM fpco/stack-build:lts-19 as build
RUN mkdir /opt/build
COPY . /opt/build
RUN cd /opt/build && stack build --system-ghc && cp -r $(stack path --local-install-root) /opt/build/output
FROM ubuntu:focal
RUN mkdir -p /opt/myapp
WORKDIR /opt/myapp
RUN apt-get update && apt-get install -y libbz2-dev libssl-dev
# RUN apt-get update && apt-get install -y \
#   ca-certificates \
#   libgmp-dev
COPY --from=build /opt/build/output output
CMD ["/opt/myapp/output/bin/unzip-stream-server-exe"]