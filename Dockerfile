FROM ubuntu:20.04

### setup environment
ENV TZ=Europe/Oslo
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
SHELL ["/bin/bash", "-c"]

### Change to local ubuntu server for faster downloads
RUN sed -i -e 's/archive.ubuntu.com/no.archive.ubuntu.com/g' /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
  ca-certificates \
  sudo \
  tmux \
  vim \
  python3-pip \
  build-essential \
  unzip \
  software-properties-common \
  git \
  ffmpeg \
  libopus-dev \
  libffi-dev \
  libsodium-dev \
  gcc \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean


# Install pip dependencies
### Install python packages
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r ./requirements.txt
RUN pip3 install --upgrade --force-reinstall --version websockets==4.0.1

# Add project source
WORKDIR /musicbot
COPY . ./

# Create volumes for audio cache, config, data and logs
VOLUME ["/musicbot/audio_cache", "/musicbot/config", "/musicbot/data", "/musicbot/logs"]

ENV PS1="(docker)${debian_chroot:+($debian_chroot)}\u@\h:\w\$ "

ENV APP_ENV=docker

#ENTRYPOINT ["python3", "dockerentry.py"]
