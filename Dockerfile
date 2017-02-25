FROM php:7.1.2-fpm-alpine

LABEL maintainer "Keng Susumpow"

ENV WP_ROOT /usr/src/wordpress
ENV WP_VERSION 4.7.2
ENV WP_SHA1 7b687f1af589c337124e6247229af209ec1d52c3
ENV WP_DOWNLOAD_URL https://wordpress.org/wordpress-$WP_VERSION.tar.gz

RUN apk add --no-cache --virtual .build-deps \
    autoconf build-base gcc imagemagick-dev libc-dev \
    libjpeg-turbo-dev libpng-dev libtool make \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd mysqli opcache \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && find /usr/local/lib/php/extensions -name '*.a' -delete \
    && find /usr/local/lib/php/extensions -name '*.so' -exec strip --strip-all '{}' \; \
    && runDeps="$( \
        scanelf --needed --nobanner --recursive \
        /usr/local/lib/php/extensions \
        | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
        | sort -u \
        | xargs -r apk info --installed \
        | sort -u \
    )" \
    && apk add --virtual .phpext-rundeps $runDeps \
    && apk del .build-deps

RUN adduser -D deployer -s /bin/bash -G www-data

RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

VOLUME /var/www/html

RUN curl -o wordpress.tar.gz -SL $WP_DOWNLOAD_URL \
	  && echo "$WP_SHA1 *wordpress.tar.gz" | sha1sum -c - \
	  && tar -xzf wordpress.tar.gz -C /usr/src/ \
	  && rm wordpress.tar.gz

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp
