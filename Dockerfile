FROM php:8-fpm

MAINTAINER A. Gökay Duman <smyrnof@gmail.com>

# Allow licenses
ENV ACCEPT_EULA=Y

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

# Update repos
RUN apt-get update \
    && apt install -y --no-install-recommends \
    apt-utils \
    gnupg \
    apt-transport-https \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*


# Install image librarries jpeg,png
RUN apt-get update \
    && apt install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install image libraries imap
RUN apt-get update \
    && apt install -y --no-install-recommends libkrb5-dev \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) imap \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install redis & xdebug
RUN pecl install redis-5.3.4 \
    && pecl install xdebug-3.1.1 \
    && docker-php-ext-enable redis xdebug

# Install other stuff
RUN apt-get update \
    && apt install -y --no-install-recommends \
                   libcurl4-openssl-dev \
                   libmcrypt-dev \
                   libxml2-dev \
                   libxslt-dev \
                   libc-client-dev \
                   libzip-dev \
                   zip \
                   libsodium-dev \
                   libonig-dev \
                   git \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*


RUN apt-get update \
    && docker-php-ext-install pdo_mysql \
                              bcmath \
                              intl \
                              opcache \
                              mysqli \
                              soap \
                              xsl \
                              zip \
                              sockets \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install MS ODBC Driver for SQL Server
RUN apt-get update \
    && apt-get install -y unixodbc unixodbc-dev \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && apt-get install -y msodbcsql17 \
    && pecl install sqlsrv pdo_sqlsrv \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN apt-get update \
    && apt-get install -y freetds-dev freetds-bin tdsodbc \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
    && docker-php-ext-install pdo_odbc

RUN apt-get update \
    && apt-get install -y nano

# LDAP client
RUN apt-get update \
    && apt-get install -y libldap2-dev \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap
