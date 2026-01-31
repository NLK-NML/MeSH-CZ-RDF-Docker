# Updated:   2026-01-30

FROM adfreiburg/qlever:latest

# Install rsync
USER root
RUN apt-get update && apt-get install -y rsync && rm -rf /var/lib/apt/lists/*

# Switch back to default user if needed
USER qlever
