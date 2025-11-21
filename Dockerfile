# Use the base Webtop image from LinuxServer.io
FROM lscr.io/linuxserver/webtop:ubuntu-xfce

# Set environment variables for non-interactive installations to prevent prompts during apt operations
ENV DEBIAN_FRONTEND=noninteractive

# Enable 32-bit architecture for multi-arch support
# This is crucial for installing 32-bit Wine components and dependencies.
RUN dpkg --add-architecture i386

# --- Start: Mirror Configuration ---
# Remove the existing sed command as it's causing an error and can be problematic with ubuntu.sources
# Instead, create a new sources list file with your desired mirror.
RUN rm -f /etc/apt/sources.list.d/ubuntu.sources && \
    echo "deb http://ir.ubuntu.sindad.cloud/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://ir.ubuntu.sindad.cloud/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://ir.ubuntu.sindad.cloud/ubuntu/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://ir.ubuntu.sindad.cloud/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list
# You might also want to add source deb lines if needed:
# echo "deb-src http://ir.ubuntu.sindad.cloud/ubuntu/ jammy main restricted universe multiverse" >> /etc/apt/sources.list
# --- End: Mirror Configuration ---

# Add WineHQ repository key
# This downloads the GPG key for the WineHQ repository and adds it to the trusted keys.
RUN wget -qO - https://dl.winehq.org/wine-builds/winehq.key | apt-key add -

# Add Google Chrome repository key (to fix the GPG error if the repo is present)
# This downloads Google's public signing key and adds it to the trusted keys.
# This is specifically to address the "NO_PUBKEY 32EE5355A6BC6E42" error for dl.google.com.
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -

# Add WineHQ repository for Ubuntu 22.04 (Jammy Jellyfish)
# Ensure 'jammy' matches the Ubuntu version of your base image.
# The repository supports both amd64 and i386 architectures.
RUN apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ jammy main'

# Update package lists after enabling multi-arch and adding all new repositories
RUN apt update