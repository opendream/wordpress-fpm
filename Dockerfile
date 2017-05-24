FROM php:7.1-fpm-alpine

LABEL maintainer "Keng Susumpow"

# Build-time metadata as defined at http://label-schema.org
 ARG BUILD_DATE
 ARG VCS_REF
 ARG VERSION
 LABEL org.label-schema.build-date=$BUILD_DATE \
       org.label-schema.name="Wordpress-FPM" \
       org.label-schema.description="A Docker container for latest version of PHP-FPM and Wordpress." \
       org.label-schema.url="https://www.opendream.co.th/" \
       org.label-schema.vcs-ref=$VCS_REF \
       org.label-schema.vcs-url="https://github.com/opendream/wordpress-fpm" \
       org.label-schema.vendor="Opendream Co., Ltd." \
       org.label-schema.version=$VERSION \
       org.label-schema.schema-version="1.0"

ENV WP_ROOT /usr/src/wordpress
ENV WP_VERSION 4.7.5
ENV WP_SHA1 fbe0ee1d9010265be200fe50b86f341587187302
ENV WP_DOWNLOAD_URL https://wordpress.org/wordpress-$WP_VERSION.tar.gz

RUN apk add --no-cache --virtual .build-deps \
    autoconf build-base gcc imagemagick-dev libc-dev pcre-dev \
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

RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN curl -o wordpress.tar.gz -SL $WP_DOWNLOAD_URL \
	  && echo "$WP_SHA1 *wordpress.tar.gz" | sha1sum -c - \
	  && tar -xzf wordpress.tar.gz -C /usr/src/ \
	  && rm wordpress.tar.gz
