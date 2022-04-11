FROM ubuntu:20.04

# install dependencies and tools
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && \
  apt-get install --no-install-recommends -y \
  ca-certificates\
  clang \
  curl \
  git \
  llvm \
  libelf-dev \
  make \
  netcat \
  openssh-server \
  openssl\
  && rm -rf /var/lib/apt/lists/*

# install kernel headers, libbpf, and bpftool
# on Ubuntu 21.01 this can be replaced with: libbpf-dev linux-tools-5.13.0-30-generic linux-cloud-tools-5.13.0-30-generic
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && \
  apt-get install --no-install-recommends -y \
  autoconf bison cmake dkms flex gawk gcc python3 rsync \
  libiberty-dev libncurses-dev libpci-dev libssl-dev libudev-dev \
  && curl https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.13.tar.gz | tar -xz \
  && make -C /linux-5.13 headers_install INSTALL_HDR_PATH=/usr \
  && make -C /linux-5.13/tools/lib/bpf install INSTALL_HDR_PATH=/usr \
  && make -C /linux-5.13/tools/bpf/bpftool install \
  && apt-get remove -y \
  autoconf bison cmake dkms flex gawk gcc python3 rsync \
  libiberty-dev libncurses-dev libpci-dev libssl-dev libudev-dev \
  && apt autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /linux-5.13

# install go
ENV GOPATH="/go"
ENV PATH="/usr/local/go/bin:$GOPATH/bin:$PATH" 

RUN curl -L https://go.dev/dl/go1.18.linux-amd64.tar.gz | tar -xz -C /usr/local;
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# configure sshd
RUN mkdir /run/sshd; \
  sed -i 's/^#\(PermitRootLogin\) .*/\1 yes/' /etc/ssh/sshd_config; \
  sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config;

# entrypoint
RUN { \
  echo '#!/bin/bash -eu'; \
  echo 'ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime'; \
  echo 'echo "root:${ROOT_PASSWORD}" | chpasswd'; \
  echo 'exec "$@"'; \
  } > /usr/local/bin/entry_point.sh; \
  chmod +x /usr/local/bin/entry_point.sh;

ENV TZ=UTC

ENV ROOT_PASSWORD root

EXPOSE 22

ENTRYPOINT ["entry_point.sh"]
CMD    ["/usr/sbin/sshd", "-D", "-e", "-p", "2222"]

