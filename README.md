[![](https://images.microbadger.com/badges/image/opendream/wordpress-fpm.svg)](https://microbadger.com/images/opendream/wordpress-fpm)
[![license](https://img.shields.io/github/license/opendream/wordpress-fpm.svg)](https://github.com/opendream/wordpress-fpm)
[![Docker Automated buil](https://img.shields.io/docker/automated/opendream/wordpress-fpm.svg)](https://hub.docker.com/r/opendream/wordpress-fpm/)

# Wordpress-FPM
A Docker container for latest version of PHP-FPM and Wordpress. 😏

This image is based on PHP's [fpm-alpine image](https://hub.docker.com/_/php/) with additional PHP extensions: `gd` `mysqli` `opcache` and `imagick`. Additional extensions will be maintained at best effort.

## Version:

* `latest` based on **Wordpress**: `4.7.2` and **PHP-FPM**: `7.1.2` [Dockerfile](https://github.com/opendream/wordpress-fpm/blob/master/Dockerfile)
