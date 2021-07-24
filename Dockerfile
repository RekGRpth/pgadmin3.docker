FROM rekgrpth/gost
CMD [ "su-exec", "pgadmin", "pgadmin3" ]
ENV GROUP=pgadmin \
    USER=pgadmin
VOLUME "${HOME}"
RUN set -eux; \
    addgroup -S "${GROUP}"; \
    adduser -D -S -h "${HOME}" -s /sbin/nologin -G "${GROUP}" "${USER}"; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
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
    mkdir -p "${HOME}/src"; \
    cd "${HOME}/src"; \
    git clone https://github.com/RekGRpth/pgadmin3.git; \
    cd "${HOME}/src/pgadmin3"; \
    ./bootstrap; \
    ./configure --prefix=/usr/local --with-wx-version=3.0 --with-openssl --enable-databasedesigner --with-libgcrypt --enable-debug; \
    make -j"$(nproc)" install; \
    cd "${HOME}"; \
    apk add --no-cache --virtual .pgadmin-rundeps \
        postgresql-client \
        su-exec \
        ttf-liberation \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build-deps; \
    find / -type f -name "*.a" -delete; \
    find / -type f -name "*.la" -delete; \
    rm -rf "${HOME}" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    echo done
