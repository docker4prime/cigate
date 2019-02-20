# docker file for cigate image
# escape=`


# ====================================
# build go components (temporary stage)
# ====================================
# base image to use
FROM alpine AS build-socks5

# args: core build dependencies
ARG DOCKER_OS_PACKAGES="bash curl git go godep make musl-dev"

# envs: go settings
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH   /go/bin:${PATH}

# create go dirs
RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

# install core dependencies
RUN apk add --no-cache ${DOCKER_OS_PACKAGES}

# switch to build dir
WORKDIR /go/src/socks5

# copy source files
COPY files/src/ .

# fetch build dependencies
RUN godep get

# build socks5
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-s' -o ${GOPATH}/bin/socks5




# ====================================
# build production image (final stage)
# ====================================
# base image
FROM alpine
MAINTAINER Fidy Andrianaivo (fidy@andrianaivo.org)
LABEL Description="cigate base image"

# APP core dependencies
ARG DOCKER_OS_PACKAGES="nginx privoxy tzdata"

# APP environments
ARG APP_NAME="cigate"
ENV APP_NAME ${APP_NAME}

# SYS environments
ARG TZ="Europe/Vienna"
ENV TZ ${TZ}

# setup application dependencies
RUN apk update \
  && apk add ${DOCKER_OS_PACKAGES} \
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
  && echo $TZ > /etc/timezone

# get go applications
COPY --from=build-socks5 /go/bin/socks5 /usr/local/bin/

# copy project binaries
COPY files/bin/ /usr/local/bin/

# copy project configs
COPY files/etc/ /etc/

# copy test files
COPY tests/ /tests/

# run premature tests
RUN echo "[>] adding temporary hosts entries" \
  && echo "127.0.0.2 appserver1" >>/etc/hosts \
  && echo "127.0.0.2 appserver2" >>/etc/hosts \
  && nginx -t -g "pid /var/run/nginx.pid;"

# define volumes
VOLUME /etc/nginx/conf.d /var/log/nginx

# expose proxy ports
EXPOSE 1080 8080

# use wrapper script as entrypoint
ENTRYPOINT ["run.sh"]

# eof
