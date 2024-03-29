# ----------------------------------------------------------------------------------------
# BUILD STAGE
# ----------------------------------------------------------------------------------------
ARG BASEIMAGE_CODE=ubuntu:22.04
FROM ${BASEIMAGE_CODE}
LABEL maintainer="aus der Technik"
LABEL Description="UItsmijter - Code-Server"

# Install OS updates and, if needed
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
RUN apt-get update && apt-get install -y apt-utils apt-transport-https
RUN apt update \
    && apt dist-upgrade -y
RUN apt install -y \
    libz-dev \
    curl libcurl4-openssl-dev wget \
    gnupg openssh-client \
    git git-lfs jq unzip \
    libjavascriptcoregtk-4.0-dev \
    python3.10 libpython3.10 python3-pip \
    binutils \
    glibc-tools gcc \
    cmake \
    sudo

# Setting up Project dir
# ----------------------------------------------------------------------------------------
RUN mkdir /Project && chmod 777 /Project
COPY scripts/entrypoint.sh /entrypoint.sh


# Install Swift
# ----------------------------------------------------------------------------------------
ARG SWIFT_VERSION
ENV SWIFT_VERSION=${SWIFT_VERSION}
WORKDIR /build
RUN echo "install..."; \
  if [ "$(arch)" = "aarch64" ]; then \
    ADD_ARCH="-$(arch)"; \
  fi; \
  echo "Arch: ${ADD_ARCH}"; \
  echo "Version: ${SWIFT_VERSION}"; \
  if [ -z ${SWIFT_VERSION+x} ]; then \
    echo "Swift version is unset."; \
    exit 1; \
  fi; \
  SWIFT_URL="https://download.swift.org/swift-${SWIFT_VERSION}-release/ubuntu2204${ADD_ARCH}/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu22.04${ADD_ARCH}.tar.gz"; \
  echo "Swift download from: ${SWIFT_URL}" > /swift_download.txt; \
  wget ${SWIFT_URL}; \
  tar -xvzf swift-${SWIFT_VERSION}-RELEASE-ubuntu22.04${ADD_ARCH}.tar.gz; \
  cd swift-${SWIFT_VERSION}-RELEASE-ubuntu22.04${ADD_ARCH}; \
  cp -rv -T ./usr/. /usr; \
  cd /; rm -rf /build/__*; ##FIXME

# Install NodeJS
# ----------------------------------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs


# Install Code-Server
# ----------------------------------------------------------------------------------------
RUN mkdir -p /extensions/install
RUN chmod -R 777 /extensions
ADD extensions/*.vsix /extensions/install/
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Download sswg.swift-lang extension (See https://github.com/swift-server/vscode-swift/issues/698)
# RUN curl "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/sswg/vsextensions/swift-lang/1.8.0/vspackage" --output "/extensions/install/swift-lang.vsix"

# Install public extensions  
RUN for ext in vadimcn.vscode-lldb zaaack.markdown-editor ms-toolsai.jupyter ms-python.python; do \
  code-server --disable-telemetry --extensions-dir /extensions --install-extension ${ext}; \
  done;

# Install user extensions
RUN for ext in $(find /extensions/install/ -name "*.vsix"); do \
  code-server --disable-telemetry --extensions-dir /extensions --install-extension ${ext}; \
  done;

RUN rm -rf /extensions/install/*

# Install Kernels
# ----------------------------------------------------------------------------------------
RUN pip install bash_kernel; python3 -m bash_kernel.install

# Setup System Preferences 
# ----------------------------------------------------------------------------------------
ENV MAX_USER_INSTANCES 2048


# Setting the startp
# ----------------------------------------------------------------------------------------
WORKDIR /Project

COPY scripts/config.yaml /root/.config/code-server/config.yaml
EXPOSE 31546
ENTRYPOINT ["/entrypoint.sh"]
