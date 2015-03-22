FROM ubuntu:14.04.2

MAINTAINER khiraiwa

# Initialize apt-get
RUN ["apt-get", "update"]
RUN ["apt-get", "install", "software-properties-common", "python-software-properties", "-y"]
RUN ["apt-get", "install", "wget", "-y"]

# Install Java
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Add subsonic user
RUN ["mkdir", "-p", "/home/subsonic/subsonic"]
RUN groupadd -r subsonic && useradd -r -d /home/subsonic -s /bin/bash -g subsonic subsonic
RUN echo 'subsonic ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Download subsonic-standalone
RUN wget -O /home/subsonic/subsonic-5.2.1-standalone.tar.gz http://downloads.sourceforge.net/project/subsonic/subsonic/5.2.1/subsonic-5.2.1-standalone.tar.gz?r=http%3A%2F%2Fwww.subsonic.org%2Fpages%2Fdownload2.jsp%3Ftarget%3Dsubsonic-5.2.1-standalone.tar.gz\ts=1426611188\use_mirror=jaist

# Unpack tar.gz
RUN ["tar", "xfz", "/home/subsonic/subsonic-5.2.1-standalone.tar.gz", "-C", "/home/subsonic/subsonic"]
RUN ["rm", "-rf", "/home/subsonic/subsonic-5.2.1-standalone.tar.gz"]

# Mount data dir
RUN ["mkdir", "/data_subsonic"]
RUN ["chown", "-R", "subsonic:subsonic", "/data_subsonic"]
VOLUME /data_subsonic:/data_subsonic

# Setup home dir
RUN ["chown", "-R", "subsonic:subsonic", "/home/subsonic"]
EXPOSE 4040

RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

RUN sed -i -e"s/SUBSONIC_HOME=\/var\/subsonic/SUBSONIC_HOME=\/data_subsonic/" /home/subsonic/subsonic/subsonic.sh
RUN sed -i -e"s/SUBSONIC_DEFAULT_MUSIC_FOLDER=\/var\/music/SUBSONIC_DEFAULT_MUSIC_FOLDER=\/data_subsonic\/music/" /home/subsonic/subsonic/subsonic.sh
RUN sed -i -e"s/SUBSONIC_DEFAULT_PODCAST_FOLDER=\/var\/music\Podcast/SUBSONIC_DEFAULT_MUSIC_FOLDER=\/data_subsonic\/music\Podcast/" /home/subsonic/subsonic/subsonic.sh
RUN sed -i -e"s/SUBSONIC_DEFAULT_PLAYLIST_FOLDER=\/var\/playlists/SUBSONIC_DEFAULT_PLAYLIST_FOLDER=\/data_subsonic\/playlists/" /home/subsonic/subsonic/subsonic.sh

WORKDIR /home/subsonic/subsonic
USER subsonic
CMD /home/subsonic/subsonic/subsonic.sh && \
  tail -100f /data_subsonic/subsonic_sh.log
