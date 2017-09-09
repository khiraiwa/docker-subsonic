FROM ubuntu:14.04.2

MAINTAINER khiraiwa

ENV SUBSONIC_VERSION 6.1.1

# Install Java, ffmpeg
RUN \
  apt-get update && \
  apt-get install software-properties-common python-software-properties wget -y && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  add-apt-repository -y ppa:mc3man/trusty-media && \
  apt-get update && \
  apt-get install -y oracle-java8-installer ffmpeg && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Add subsonic user
RUN \
  mkdir -p /home/subsonic/subsonic && \
  groupadd -r subsonic && useradd -r -d /home/subsonic -s /bin/bash -g subsonic subsonic && \
  echo 'subsonic ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Download subsonic-standalone
RUN \
  wget -O /home/subsonic/subsonic-${SUBSONIC_VERSION}-standalone.tar.gz https://s3-eu-west-1.amazonaws.com/subsonic-public/download/subsonic-${SUBSONIC_VERSION}-standalone.tar.gz && \
  tar xfz /home/subsonic/subsonic-${SUBSONIC_VERSION}-standalone.tar.gz -C /home/subsonic/subsonic && \
  rm -rf /home/subsonic/subsonic-${SUBSONIC_VERSION}-standalone.tar.gz

# Mount data dir and setup home dir
RUN \
  mkdir /data_subsonic && \
  chown -R subsonic:subsonic /data_subsonic && \
  chown -R subsonic:subsonic /home/subsonic
VOLUME ["/data_subsonic"]

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# Setup Subsonic settings
RUN \
  sed -i -e"s/SUBSONIC_HOME=\/var\/subsonic/SUBSONIC_HOME=\/data_subsonic/" /home/subsonic/subsonic/subsonic.sh && \
  sed -i -e"s/SUBSONIC_DEFAULT_MUSIC_FOLDER=\/var\/music/SUBSONIC_DEFAULT_MUSIC_FOLDER=\/data_subsonic\/music/" /home/subsonic/subsonic/subsonic.sh && \
  sed -i -e"s/SUBSONIC_DEFAULT_PODCAST_FOLDER=\/var\/music\Podcast/SUBSONIC_DEFAULT_MUSIC_FOLDER=\/data_subsonic\/music\Podcast/" /home/subsonic/subsonic/subsonic.sh && \
  sed -i -e"s/SUBSONIC_DEFAULT_PLAYLIST_FOLDER=\/var\/playlists/SUBSONIC_DEFAULT_PLAYLIST_FOLDER=\/data_subsonic\/playlists/" /home/subsonic/subsonic/subsonic.sh && \
  mkdir -p /data_subsonic/transcode && \
  ln -s /usr/bin/ffmpeg /data_subsonic/transcode/ffmpeg

WORKDIR /home/subsonic/subsonic
USER subsonic
EXPOSE 4040

CMD /home/subsonic/subsonic/subsonic.sh && \
  tail -100f /data_subsonic/subsonic_sh.log
