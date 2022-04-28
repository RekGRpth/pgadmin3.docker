FROM ghcr.io/rekgrpth/gost.docker:latest
CMD [ "gosu", "pgadmin", "pgadmin3" ]
ENV GROUP=pgadmin \
    USER=pgadmin
RUN set -eux; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    addgroup -S "$GROUP"; \
    adduser -S -D -G "$GROUP" -H -h "$HOME" -s /sbin/nologin "$USER"; \
    apk add --no-cache --virtual .build \
        autoconf \
        automake \
        g++ \
        gcc \
        git \
        libgcrypt-dev \
        libxml2-dev \
        libxslt-dev \
        linux-headers \
        make \
        musl-dev \
#        openssl3-dev \
        postgresql-dev \
        wxgtk-dev \
    ; \
    mkdir -p "$HOME/src"; \
    cd "$HOME/src"; \
    git clone https://github.com/RekGRpth/pgadmin3.git; \
    cd "$HOME/src/pgadmin3"; \
    ./bootstrap; \
    ./configure --prefix=/usr/local --with-wx-version=3.0 --with-openssl --enable-databasedesigner --with-libgcrypt --enable-debug; \
    make -j"$(nproc)" install; \
    cd /; \
    apk add --no-cache --virtual .pgadmin \
        postgresql-client \
        su-exec \
        ttf-liberation \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | grep -v "^$" | grep -v -e libcrypto | sort -u | while read -r lib; do test -z "$(find /usr/local/lib -name "$lib")" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build; \
    rm -rf "$HOME" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find /usr -type f -name "*.la" -delete; \
    mkdir -p "$HOME"; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    echo done
