FROM php:7.2.12-fpm-alpine

ENV SMProxy_VERSION 1.2.4

ADD https://github.com/louislivi/smproxy/releases/download/v$SMProxy_VERSION/smproxy.tar.gz /usr/local

RUN printf "\n" | pecl install -f swoole && \
    docker-php-ext-enable swoole && \
    cd /usr/local && \
    tar -zxvf smproxy.tar.gz && \
    ls -lna

VOLUME /usr/local/smproxy/conf

VOLUME /usr/local/smproxy/logs

EXPOSE 3366

CMD ["/usr/local/smproxy/SMProxy", "start"]
