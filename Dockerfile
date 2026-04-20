FROM node:lts-alpine

ARG PUID=1000
ARG PGID=1000

# shadow provides groupadd/useradd (matches htpc custom-build convention)
RUN apk add --no-cache shadow

# Shared pipx location so the non-root app user can run pdfcropmargins
ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin

RUN apk add --no-cache pipx && pipx install pdfCropMargins

# Download and install kepubify (pinned SHA256)
RUN wget https://github.com/pgaskin/kepubify/releases/download/v4.0.4/kepubify-linux-64bit && \
    echo "37d7628d26c5c906f607f24b36f781f306075e7073a6fe7820a751bb60431fc5  kepubify-linux-64bit" | sha256sum -c && \
    mv kepubify-linux-64bit /usr/local/bin/kepubify && \
    chmod +x /usr/local/bin/kepubify

# Download and install kindlegen (pinned SHA256)
RUN wget https://github.com/zzet/fp-docker/raw/f2b41fb0af6bb903afd0e429d5487acc62cb9df8/kindlegen_linux_2.6_i386_v2_9.tar.gz && \
    echo "9828db5a2c8970d487ada2caa91a3b6403210d5d183a7e3849b1b206ff042296  kindlegen_linux_2.6_i386_v2_9.tar.gz" | sha256sum -c && \
    mkdir -p /tmp/kg && \
    tar xf kindlegen_linux_2.6_i386_v2_9.tar.gz --directory /tmp/kg && \
    cp /tmp/kg/kindlegen /usr/local/bin/kindlegen && \
    chmod +x /usr/local/bin/kindlegen && \
    rm -rf /tmp/kg kindlegen_linux_2.6_i386_v2_9.tar.gz

# Create user/group matching host PUID/PGID.
# node:alpine ships with a pre-existing `node` user at UID/GID 1000 — remove
# it first so we can claim the UID/GID regardless of what PUID/PGID are set to.
RUN userdel node 2>/dev/null || true; \
    groupdel node 2>/dev/null || true; \
    groupadd -g "${PGID}" s2e \
    && useradd -u "${PUID}" -g s2e -m -s /sbin/nologin s2e

WORKDIR /usr/src/app
RUN chown s2e:s2e /usr/src/app

# Copy package manifests + patches first so npm install's postinstall
# (patch-package) can find ./patches/
COPY --chown=s2e:s2e package*.json ./
COPY --chown=s2e:s2e patches ./patches

USER s2e

RUN npm install --omit=dev

COPY --chown=s2e:s2e . ./

RUN mkdir -p uploads

EXPOSE 3001
CMD ["npm", "start"]
