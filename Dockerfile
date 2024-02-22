FROM alpine:edge AS build

RUN set -x \
  && apk add --no-cache \
      build-base cmake cargo curl jq \
  && mkdir -p /root/shadowsocks-rust \
  && cd /root/shadowsocks-rust \
  && latest_release=$(curl -s "https://api.github.com/repos/shadowsocks/shadowsocks-rust/releases/latest" | jq -r '.tag_name') \
  && curl -s -L "https://github.com/shadowsocks/shadowsocks-rust/archive/refs/tags/${latest_release}.tar.gz" | tar -xzf - --strip-components=1 \
  && cargo build --release --features "full full-extra" \
  && echo done

FROM alpine:edge AS final-client

RUN set -x \
  && apk add --no-cache \
      libgcc \
  && echo done

COPY --from=build /root/shadowsocks-rust/target/release/ssservice /usr/bin/
COPY --from=build /root/shadowsocks-rust/target/release/sslocal /usr/bin/
COPY --from=build /root/shadowsocks-rust/target/release/ssurl /usr/bin/
COPY --from=build /root/shadowsocks-rust/examples/config.json /etc/shadowsocks-rust/

ADD files/config.json /root/
ADD files/entrypoint.sh /usr/bin/

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "ssservice", "local", "--log-without-time", "-c", "/etc/shadowsocks-rust/config.json" ]

FROM alpine:edge AS final-server

RUN set -x \
  && apk add --no-cache \
      libgcc \
  && echo done

COPY --from=build /root/shadowsocks-rust/target/release/ssservice /usr/bin/
COPY --from=build /root/shadowsocks-rust/target/release/ssserver /usr/bin/
COPY --from=build /root/shadowsocks-rust/target/release/ssurl /usr/bin/

ADD files/config.json /root/
ADD files/entrypoint.sh /usr/bin/

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "ssservice", "server", "--log-without-time", "-a", "nobody", "-c", "/etc/shadowsocks-rust/config.json" ]
