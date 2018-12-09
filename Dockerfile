FROM php:7.2.12-cli-alpine

#ENV SMProxy_VERSION 1.2.4

# PHP Composer
RUN wget https://dl.laravel-china.org/composer.phar -O /usr/local/bin/composer \
    && chmod a+x /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://packagist.laravel-china.org

RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS linux-headers git \
    && pecl install swoole \
    && docker-php-ext-enable swoole \
    && git clone https://github.com/louislivi/SMProxy.git /usr/local/smproxy \
    && cd /usr/local/smproxy \
    && composer install --no-dev \
    \
    # xBring in gettext so we can get `envsubst`, then throw
    # the rest away. To do this, we need to install `gettext`
    # then move `envsubst` out of the way so `gettext` can
    # be deleted completely, then move `envsubst` back.
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    \
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' /usr/local/bin/php /usr/local/lib/php/extensions/*/*.so /tmp/envsubst \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --no-cache --virtual .php-rundeps $runDeps \
    && apk del .phpize-deps \
    && apk del .gettext \
    && mv /tmp/envsubst /usr/local/bin/ \
    \
#    && cd /usr/local \
#    && wget https://github.com/louislivi/smproxy/releases/download/v$SMProxy_VERSION/smproxy.tar.gz \
#    && tar -zxvf smproxy.tar.gz \
    && ls -lna

VOLUME /usr/local/smproxy/conf

VOLUME /usr/local/smproxy/logs

EXPOSE 3366

CMD ["/usr/local/smproxy/bin/SMProxy", "start", "--console"]
