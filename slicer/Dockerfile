# Rebel CAD's slicer: Bambu Studio (AGPL-3.0, bambulab/BambuStudio) from its official release, run headless as its own
# program per job (--network none, limits, a timeout): never linked into Rebel CAD. Version and sha256 in VERSION.
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
      libgtk-3-0t64 libwebkit2gtk-4.1-0 libgl1 libegl1 libglu1-mesa libosmesa6 libgstreamer1.0-0 \
      libgstreamer-plugins-base1.0-0 libsecret-1-0 libfuse2t64 ca-certificates fonts-dejavu-core file \
    && rm -rf /var/lib/apt/lists/*
# the AppImage (verified against the release's sha256 by build.sh before it gets here), extracted: no FUSE at run time
COPY .cache/BambuStudio-24.04.AppImage /tmp/bs.AppImage
RUN chmod +x /tmp/bs.AppImage && cd /opt && /tmp/bs.AppImage --appimage-extract >/dev/null && mv squashfs-root bambustudio \
    && rm /tmp/bs.AppImage && chmod -R a+rX /opt/bambustudio
# the command line reads a printer's model id (slice_info's printer_model_id) from profiles/BBL/machine_full/, which the
# release does not ship: the machine_model presets carry it.
RUN cd /opt/bambustudio/resources/profiles/BBL && mkdir -p machine_full \
    && for f in machine/*.json; do grep -q '"type": *"machine_model"' "$f" && cp "$f" machine_full/; done; \
    ls machine_full | grep -q 'H2D.json'
COPY slice.sh /usr/local/bin/slice
RUN chmod +x /usr/local/bin/slice && useradd -m -u 1001 slicer
USER slicer
WORKDIR /job
ENTRYPOINT ["/usr/local/bin/slice"]
