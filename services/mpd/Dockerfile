FROM debian:bullseye-slim

# Install MPD and additional audio packages
RUN apt-get update && apt-get install -y mpd && rm -rf /var/lib/apt/lists/*

# Create all required directories with correct ownership
RUN mkdir -p /var/lib/mpd/music /var/lib/mpd/playlists /var/lib/mpd && \
    chown -R mpd /var/lib/mpd

# Copy MPD configuration
COPY mpd.conf /etc/mpd.conf

# Expose MPD port
EXPOSE 6600

# Switch to mpd user
USER mpd

# Start MPD
CMD ["mpd", "--no-daemon", "/etc/mpd.conf"] 