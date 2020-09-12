ARG ARCH=
ARG BUILD_DATE=

FROM ${ARCH}debian:buster-slim

ENV elastic_version='7.9.1'
ENV tarball='logstash-oss-'${elastic_version}'.tar.gz'
ENV license='Apache 2.0'
ENV locale='de_AT.UTF-8'

RUN mkdir -p /usr/share/man/man1

RUN apt-get update \
    && apt-get install -y procps findutils tar gzip openjdk-11-jre curl \
    && rm -rf /var/lib/apt/lists/*

# Provide a non-root user to run the process. 
RUN groupadd --gid 1000 logstash && \
    adduser --uid 1000 --gid 1000 \
      --home /usr/share/logstash --no-create-home \
      logstash

# Add Logstash itself.
RUN curl -k -Lo - https://artifacts.elastic.co/downloads/logstash/${tarball} | \
    tar zxf - -C /usr/share && \
    mv /usr/share/logstash-${elastic_version} /usr/share/logstash && \
    chown --recursive logstash:logstash /usr/share/logstash/ && \
    chown -R logstash:root /usr/share/logstash && \
    chmod -R g=u /usr/share/logstash && \
    find /usr/share/logstash -type d -exec chmod g+s {} \; && \
    ln -s /usr/share/logstash /opt/logstash

WORKDIR /usr/share/logstash

ENV ELASTIC_CONTAINER true
ENV PATH=/usr/share/logstash/bin:$PATH

# Provide a minimal configuration, so that simple invocations will provide
# a good experience.
ADD config/pipelines.yml config/pipelines.yml
ADD config/logstash-oss.yml config/logstash.yml
ADD config/log4j2.properties config/
ADD pipeline/default.conf pipeline/logstash.conf
RUN chown --recursive logstash:root config/ pipeline/

# Ensure Logstash gets the correct locale by default.
#ENV LANG=${locale} LC_ALL=${locale}

# Place the startup wrapper script.
ADD bin/docker-entrypoint /usr/local/bin/
RUN chmod 0755 /usr/local/bin/docker-entrypoint

USER 1000

ADD env2yaml/env2yaml /usr/local/bin/

EXPOSE 9600 5044

LABEL  org.label-schema.schema-version="1.0" \
  org.label-schema.vendor="Elastic" \
  org.opencontainers.image.vendor="Elastic" \
  org.label-schema.name="logstash" \
  org.opencontainers.image.title="logstash" \
  org.label-schema.version="${elastic_version}" \
  org.opencontainers.image.version="${elastic_version}" \
  org.label-schema.url="https://www.elastic.co/products/logstash" \
  org.label-schema.vcs-url="https://github.com/elastic/logstash" \
  license="${license}" \
  org.label-schema.license="${license}" \
  org.opencontainers.image.licenses="${license}" \
  org.label-schema.build-date=${BUILD_DATE} \
  org.opencontainers.image.created=${BUILD_DATE}

#ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
ENTRYPOINT ["/bin/bash"]