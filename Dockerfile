FROM rekgrpth/gost
CMD [ "su-exec", "pgadmin", "pgadmin3" ]
ENV GROUP=pgadmin \
    USER=pgadmin
VOLUME "${HOME}"
RUN set -eux; \
    addgroup -S "${GROUP}"; \
    adduser -D -S -h "${HOME}" -s /sbin/nologin -G "${GROUP}" "${USER}"; \
    apk add --no-cache --virtual .build-deps \
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
        openssl-dev \
        postgresql-dev \
        wxgtk-dev \
    ; \
    mkdir -p /usr/src; \
    cd /usr/src; \
    git clone --recursive https://github.com/RekGRpth/pgadmin3.git; \
    cd /usr/src/pgadmin3; \
    ./bootstrap; \
    ./configure --prefix=/usr/local --with-wx-version=3.0 --with-openssl --enable-databasedesigner --with-libgcrypt --enable-debug; \
    make -j"$(nproc)" install; \
    apk add --no-cache --virtual .pgadmin-rundeps \
        postgresql-client \
        su-exec \
        ttf-liberation \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin /usr/local/lib -type f -exec strip '{}' \;; \
    apk del --no-cache .build-deps; \
    rm -rf /usr/src /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find / -name "*.a" -delete; \
    find / -name "*.la" -delete; \
    echo done
