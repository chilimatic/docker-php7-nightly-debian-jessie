#
# PHP7 Nightly Build / Debian Jessie / Nginx
#

FROM debian:jessie
MAINTAINER Jakob Oberhummer <php7@chilimatic.com>

# update the resources first
RUN apt-get -y update

# install dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git \ 
	make \
	autoconf \
	libpcre3 \
	libpcre3-dev \
	build-essential \
	bison \
	libbz2-dev \
	libpng12-dev \
	libfreetype6-dev \
	libgmp3-dev \
	libmcrypt-dev \
	libmysqlclient-dev \
	libpspell-dev \
	librecode-dev \
	libxml2-dev \
	libcurl4-openssl-dev \
	libjpeg-dev \
	libpng-dev \
	libxpm-dev \
	libmysqlclient-dev \
	libpq-dev \
	libicu-dev \
	libfreetype6-dev \
	libldap2-dev \
	libxslt-dev \
	openssl \
	libcurl4-openssl-dev \
	pkg-config \
	git \
	libtool \
	gettext \
	libreadline-dev \
	supervisor

# clone and build PHP 7
RUN git clone https://github.com/php/php-src.git /tmp/php-src/
WORKDIR /tmp/php-src/ 

# build && compile PHP 7
RUN ./buildconf 

# more informations about the configurations are
# http://www.phpinternalsbook.com/build_system/building_php.html 
# http://php.net/manual/en/configure.about.php
#  ./configure --help to see all the options (at least the most common)
RUN ./configure \
	--prefix=/usr/php \
	--enable-mbstring \
	--with-curl \
	--with-openssl \
	--with-xmlrpc \
	--enable-soap \
	--enable-zip \
	--with-gd \
	--with-jpeg-dir \
	--with-png-dir \
	--with-pgsql \
	--enable-embedded-mysqli \
	--with-freetype-dir \
	--enable-intl \
	--with-xsl \
	--with-mysqli \
	--with-pdo-mysql \
	--enable-pdo=shared \
	--with-pdo-mysql=shared \
	--with-pdo-sqlite=shared \
	--with-pdo-pgsql=shared \
	--with-config-file-path=/etc/php/ \
	--disable-short-tags \
	--enable-phpdbg \
	--with-readline \
	--with-gettext \
	--enable-opcache \
	--enable-debug \
	--enable-intl \
	--enable-mbstring \
	--enable-pcntl \
	--enable-sockets \
	--enable-sysvmsg \
	--enable-sysvsem \
	--enable-sysvshm \
	--enable-ftp \
	--enable-fpm \
    	--with-fpm-user=www-data \
	--with-fpm-group=www-data

RUN make 
RUN make install

# create symlinks for the binaries (needed for execution without the absolute path)
RUN ln -s /usr/php/bin/* /usr/bin/
RUN ln -s /usr/php/sbin/* /usr/sbin/

# building of extensions would be like this both are not working since the php core has been changed in php7 but maybe in time
# Mongo DB
# RUN git clone https://github.com/mongodb/mongo-php-driver.git /tmp/mongo-php
# WORKDIR /tmp/mongo-php/ 
# RUN phpize
# RUN ./configure 
# RUN make all
# RUN make install

# redis <- this results in an error for the moment (fatal error: ext/standard/php_smart_str.h: No such file or directory)
# RUN git clone https://github.com/phpredis/phpredis /tmp/redis-php
# WORKDIR /tmp/redis-php/ 
# RUN phpize
# RUN ./configure 
# RUN make all
# RUN make install


# create the configuration structure
RUN mkdir -p /etc/php/fpm/conf.d /etc/php/fpm/pool.d
RUN mkdir -p /etc/php/cli/conf.d 
RUN mkdir -p /var/run/sshd

# copy my template files to the docker path
COPY php/mods-available/* /etc/php/mods-available/
COPY php/fpm/*.ini /etc/php/fpm/
COPY php/fpm/*.conf /etc/php/fpm/
COPY php/fpm/pool.d/*.conf /etc/php/fpm/pool.d/
COPY php/fpm/conf.d/*.ini /etc/php/fpm/conf.d/
COPY php/cli/*.ini /etc/php/cli/
COPY php/cli/conf.d/*.ini /etc/php/cli/conf.d/

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

#cleanup lateron
RUN rm -rf /tmp/*

# service for init.d
CMD ["/usr/bin/supervisord"]

