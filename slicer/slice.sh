#!/bin/bash
# One slicing job: Bambu Studio's command line, no display (its plate thumbnails need a Wayland display, so the 3mf has
# none; Rebel CAD shows its own preview). The job dir is /job: the server writes the presets and the models to in/ and
# reads out/ and log.txt back.
# Usage: slice <args for bambu-studio>
set -uo pipefail
export HOME=/tmp/home; mkdir -p "$HOME"
/opt/bambustudio/AppRun "$@" > /job/log.txt 2>&1
rc=$?
echo "EXIT $rc" >> /job/log.txt
exit $rc
