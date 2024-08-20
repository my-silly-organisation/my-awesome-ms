# Build Stage
FROM lacion/alpine-golang-buildimage:1.18 AS build-stage

LABEL app="build-my-awesome-ms"
LABEL REPO="https://github.com/lacion/my-awesome-ms"

ENV PROJPATH=/go/src/github.com/lacion/my-awesome-ms

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/lacion/my-awesome-ms
WORKDIR /go/src/github.com/lacion/my-awesome-ms

RUN make build-alpine

# Final Stage
FROM lacion/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/lacion/my-awesome-ms"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/my-awesome-ms/bin

WORKDIR /opt/my-awesome-ms/bin

COPY --from=build-stage /go/src/github.com/lacion/my-awesome-ms/bin/my-awesome-ms /opt/my-awesome-ms/bin/
RUN chmod +x /opt/my-awesome-ms/bin/my-awesome-ms

# Create appuser
RUN adduser -D -g '' my-awesome-ms
USER my-awesome-ms

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/my-awesome-ms/bin/my-awesome-ms"]
