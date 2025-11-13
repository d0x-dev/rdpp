# Web-based RDP Gateway - Works on Railway
FROM linuxserver/webtop:ubuntu-xfce

# Set environment variables
ENV PUID=1000
ENV PGID=1000
ENV TZ=UTC
ENV USERNAME=administrator
ENV PASSWORD=Darkboy336

# Expose web port
EXPOSE 3000

# No additional setup needed - everything runs via web browser
