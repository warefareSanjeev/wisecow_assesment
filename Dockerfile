
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

ENV SRVPORT=4499
ENV RSPFILE=/tmp/wisecow_rsp


RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash \
       netcat-openbsd \
       fortune-mod \
       cowsay \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -r -u 10001 -g nogroup wisecow

WORKDIR /app
RUN touch ${RSPFILE} && chown wisecow:nogroup ${RSPFILE}

COPY wisecow.sh /app/wisecow.sh
RUN chmod +x /app/wisecow.sh

USER wisecow

EXPOSE ${SRVPORT}

HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD \
  /bin/bash -c "timeout 3 bash -lc '</dev/tcp/127.0.0.1/${SRVPORT}'" || exit 1

ENTRYPOINT ["/bin/bash", "-c", "/app/wisecow.sh"]
