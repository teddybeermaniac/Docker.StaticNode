FROM alpine:3.19.0 AS base

RUN apk add --no-cache \
    build-base \
    busybox-static

FROM base AS node

RUN apk add --no-cache \
    brotli-dev \
    brotli-static \
    c-ares-dev \
    c-ares-static \
    icu-data-full \
    icu-dev \
    icu-static \
    libuv-dev \
    libuv-static \
    linux-headers \
    nghttp2-dev \
    nghttp2-static \
    nghttp3-dev \
    openssl-dev \
    openssl-libs-static \
    python3 \
    zlib-dev \
    zlib-static

ARG NODE_VERSION=20.10.0

WORKDIR /build
RUN wget -O "/build/node-v${NODE_VERSION}.tar.xz" "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.xz" && \
    tar -xf "/build/node-v${NODE_VERSION}.tar.xz"

WORKDIR "/build/node-v${NODE_VERSION}"
RUN "/build/node-v${NODE_VERSION}/configure" \
    --fully-static \
    --no-cross-compiling \
    --openssl-use-def-ca-store \
    --openssl-system-ca-path /etc/ssl/certs/ca-certificates.crt \
    --enable-static \
    --shared-brotli \
    --shared-brotli-libname brotlidec,brotlienc,brotlicommon \
    --shared-cares \
    #--shared-http-parser \
    --shared-libuv \
    --shared-nghttp2 \
    --shared-nghttp3 \
    #--shared-ngtcp2 \
    --shared-openssl \
    --shared-zlib \
    --with-intl system-icu \
    --without-corepack \
    --without-inspector \
    --without-npm \
    --prefix / && \
    make -j "$(nproc --all)" DESTDIR=/install install && \
    strip /install/bin/node

FROM ghcr.io/teddybeermaniac/docker.scratchbase:v0.1.4

COPY --from=node /install/bin/node /bin/node

RUN --mount=from=base,source=/bin/busybox.static,target=/bin/busybox \
    --mount=from=base,source=/bin/busybox.static,target=/bin/sh \
    --mount=from=node,source=/usr/share/icu,target=/mnt/icu \
    busybox find /mnt/icu -mindepth 2 -iname 'icudt*.dat' | while read FILE; do busybox install -D "${FILE}" "${FILE/\/mnt/\/usr\/share}"; done

CMD [ "node", "/app/index.js" ]
