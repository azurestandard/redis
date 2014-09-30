# ┌────────────────────────────────────────────────────────────────────┐
# │ Redis                                                              │
# │ https://github.com/azurestandard/redis                             │
# ├────────────────────────────────────────────────────────────────────┤
# │ Copyright © 2014 Jordan Schatz                                     │
# │ Copyright © 2014 Azure Standard (http://www.azurestandard.com)     │
# ├────────────────────────────────────────────────────────────────────┤
# │ Licensed under the MIT License                                     │
# └────────────────────────────────────────────────────────────────────┘

# Originally from https://github.com/docker-library/redis/blob/master/2.6.17/Dockerfile

# Start from docker's debian:wheezy which is currently the most
# minimal and trust worthy
# https://registry.hub.docker.com/_/debian/
FROM debian:wheezy

MAINTAINER Jordan Schatz "jordan@noionlabs.com"

FROM debian:wheezy

# add our user and group first to make sure their IDs get assigned
# consistently, regardless of whatever dependencies get added
RUN groupadd -r redis && useradd -r -g redis redis

ENV REDIS_VERSION 2.6.17
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-2.6.17.tar.gz
ENV REDIS_DOWNLOAD_SHA1 b5423e1c423d502074cbd0b21bd4e820409d2003

# To minimize image size, we run this as a single layer, and clean up
# after ourselves.
RUN buildDeps='gcc libc6-dev make'; \
    set -x; \
    apt-get update && apt-get install -y $buildDeps curl --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /usr/src/redis \
    && curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
    && echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && rm redis.tar.gz \
    && make -C /usr/src/redis \
    && make -C /usr/src/redis install \
    && rm -r /usr/src/redis \
    && apt-get purge -y $buildDeps curl \
    && apt-get autoremove -y

RUN mkdir /data && chown redis /data
WORKDIR /data
USER redis
EXPOSE 6379
CMD [ "redis-server" ]
