#!/bin/sh

set -eo pipefail

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export SUBSONIC_HOME="/data_subsonic"
export SUBSONIC_DEFAULT_MUSIC_FOLDER="/data_subsonic/music"
export SUBSONIC_DEFAULT_PODCAST_FOLDER="/data_subsonic/music/Podcast"
export SUBSONIC_DEFAULT_PLAYLIST_FOLDER="/data_subsonic/playlists"

mkdir -p /data_subsonic/transcode
ln -s /usr/bin/ffmpeg /data_subsonic/transcode/ffmpeg

case "$1" in
    subsonic)
        /root/subsonic.sh
        while [ ! -e "/data_subsonic/subsonic_sh.log" ]; do sleep 1s; done
        tail -f /data_subsonic/subsonic_sh.log
        exit 0
        ;;

    help)
        echo "nothing."
        exit 0
        ;;
esac

exec "$@"
