FROM rekgrpth/gost
CMD [ "su-exec", "pgadmin3", "pgadmin3" ]
ENV GROUP=pgadmin3 \
    USER=pgadmin3
VOLUME "${HOME}"
RUN set -ex \
    && addgroup -S "${GROUP}" \
    && adduser -D -S -h "${HOME}" -s /sbin/nologin -G "${GROUP}" "${USER}" \
    && apk add --no-cache --virtual .build-deps \
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
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone --recursive https://github.com/RekGRpth/pgadmin3.git \
    && cd /usr/src/pgadmin3 \
    && ./bootstrap \
    && ./configure --prefix=/usr/local --with-wx-version=3.0 --with-openssl --enable-databasedesigner --with-libgcrypt \
    && make -j"$(nproc)" install \
    && (strip /usr/local/bin/* /usr/local/lib/*.so || true) \
    && apk add --no-cache --virtual .pgadmin-rundeps \
        postgresql-client \
        ttf-liberation \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }') \
    && apk del --no-cache .build-deps \
    && echo Done
