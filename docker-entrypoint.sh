#!/bin/sh

set -eo pipefail

/root/subsonic.sh && tail -f /data_subsonic/subsonic_sh.log

#exec "$@"
