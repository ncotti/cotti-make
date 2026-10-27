ARG RENODE_INSTALL_PATH="/opt/renode"
ARG VERILATOR_INSTALL_PATH="/opt/verilator"

FROM ubuntu:26.04 AS build_renode
    ARG RENODE_INSTALL_PATH

    RUN apt-get update \
        && apt-get install -y --no-install-recommends \
            wget tar gzip ca-certificates \
        && update-ca-certificates \
        && rm -rf /var/lib/apt/lists/*

    RUN mkdir -p "${RENODE_INSTALL_PATH}" \
        && wget -qO- https://builds.renode.io/renode-latest.linux-portable.tar.gz | \
            tar -xz --strip-components=1 -C "${RENODE_INSTALL_PATH}"

# Installation steps taken from
# https://veripool.org/guide/latest/install.html
FROM ubuntu:26.04 AS build_verilator
    ARG VERILATOR_VERSION="v5.052"
    ARG VERILATOR_INSTALL_PATH

    RUN apt-get update \
        && apt-get install -y --no-install-recommends \
            git help2man perl python3 make autoconf g++ flex bison ccache \
            libgoogle-perftools-dev libjemalloc-dev numactl perl-doc \
            libfl2 \
            libfl-dev \
            zlib1g zlib1g-dev liblz4-dev \
            make \
            ca-certificates \
        && update-ca-certificates \
        && rm -rf /var/lib/apt/lists/*

    RUN git clone https://github.com/verilator/verilator \
        && cd verilator \
        && git checkout ${VERILATOR_VERSION} \
        && autoconf \
        && ./configure --prefix="${VERILATOR_INSTALL_PATH}" \
        && make -j $(nproc) \
        && make install

FROM ubuntu:26.04 AS target
    ARG VERILATOR_INSTALL_PATH
    ARG RENODE_INSTALL_PATH

    # Copy all built binaries from build stages
    COPY --from=build_renode ${RENODE_INSTALL_PATH} ${RENODE_INSTALL_PATH}
    COPY --from=build_verilator ${VERILATOR_INSTALL_PATH} ${VERILATOR_INSTALL_PATH}

    ENV PATH="${PATH}:${RENODE_INSTALL_PATH}:${VERILATOR_INSTALL_PATH}/bin"

    # Install all needed packages
    RUN apt-get update \
        && apt-get install -y --no-install-recommends \
            # Essentials
            make \
            # C-toolchain
            gcc clang clang-tidy clang-format bear \
            # Cross compilation
            gcc-arm-none-eabi libnewlib-arm-none-eabi \
            # Debugging
            gdb gdb-multiarch \
            # Simulation
            gnome-terminal qemu-system-arm \
            # Cocotb
            python3 pip \
        && rm -rf /var/lib/apt/lists/*

    # Install Python packages
    COPY docker/requirements.txt /tmp/requirements.txt
    RUN pip install --break-system-packages -r /tmp/requirements.txt \
        && rm /tmp/requirements.txt

    CMD [ "/bin/bash" ]