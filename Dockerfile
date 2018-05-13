FROM alpine:latest as downloader

ENV SUBSONIC_VERSION 6.1.3

RUN apk --no-cache add wget ca-certificates ffmpeg && \
  update-ca-certificates

# Download subsonic-standalone
RUN mkdir -p /opt/subsonic && \
  wget -O /opt/subsonic.tar.gz \
  https://s3-eu-west-1.amazonaws.com/subsonic-public/download/subsonic-${SUBSONIC_VERSION}-standalone.tar.gz && \
  tar xfz /opt/subsonic.tar.gz -C /opt/subsonic && \
  rm -rf /opt/subsonic.tar.gz

FROM java:8-jre-alpine

MAINTAINER khiraiwa <the.world.nova@gmail.com>

VOLUME ["/data_subsonic"]

# Install ffmpeg, root certificates
RUN apk --no-cache add ffmpeg ca-certificates && \
    update-ca-certificates

WORKDIR /root/
EXPOSE 4040

COPY --from=downloader /opt/subsonic/subsonic-booter-jar-with-dependencies.jar \
     /opt/subsonic/subsonic.war /opt/subsonic/subsonic.sh ./

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["subsonic"]