FROM debian:trixie-20260316

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        tini nginx procps

ENTRYPOINT ["/usr/bin/tini", "--", "nginx"]

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["-g", "daemon off;"]
