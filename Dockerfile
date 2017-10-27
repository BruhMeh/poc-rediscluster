FROM debian:latest

MAINTAINER Bruno Delgado <bruno.sdelgado@outlook.com>

# Some Environment Variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -yqq \
      net-tools supervisor ruby-full rubygems locales gettext-base wget && \
    apt-get clean -yqq

# # Ensure UTF-8 lang and locale
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

RUN gem install rubygems-update -v 2.2.3

RUN gem install redis

RUN apt-get install -y gcc make g++ build-essential libc6-dev tcl git supervisor ruby-full

RUN git clone -b 4.0.2 https://github.com/antirez/redis.git /redis

RUN (cd /redis && make)

RUN mkdir /redis-conf
RUN mkdir /redis-data

COPY ./docker-data/redis-cluster.tmpl /redis-conf/redis-cluster.tmpl
COPY ./docker-data/redis.tmpl /redis-conf/redis.tmpl

# Add startup script
COPY ./docker-data/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 755 /docker-entrypoint.sh

EXPOSE 7000 7001 7002 7003 7004 7005

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["redis-cluster"]
