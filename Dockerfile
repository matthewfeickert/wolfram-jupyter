ARG BASE_IMAGE=wolframresearch/wolframengine:13.3.0
FROM ${BASE_IMAGE} as base

SHELL [ "/bin/bash", "-c" ]

FROM base as builder

USER root

# Set PATH to pickup virtualenv by default
ENV PATH=/usr/local/venv/bin:"${PATH}"
ARG PYTHON_VERSION=3.11
RUN apt-get -qq -y update && \
    apt-get -qq -y install \
      software-properties-common \
      wget \
      curl \
      git && \
    apt-get update && \
    add-apt-repository -y 'ppa:deadsnakes/ppa' && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
        python"${PYTHON_VERSION}" \
        python"${PYTHON_VERSION}"-venv \
        binutils \
        binfmt-support && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    python"${PYTHON_VERSION}" -m venv /usr/local/venv && \
    . /usr/local/venv/bin/activate && \
    python -m pip --no-cache-dir install --upgrade pip setuptools wheel && \
    python -m pip --no-cache-dir install --upgrade notebook jupyterlab && \
    python -m pip list

FROM base

USER root

SHELL [ "/bin/bash", "-c" ]
ENV PATH=/usr/local/venv/bin:"${PATH}"

# Install any packages needed by default user
ARG PYTHON_VERSION=3.11
RUN apt-get -qq -y update && \
    apt-get -qq -y install \
      software-properties-common \
      wget \
      curl \
      git && \
    apt-get update && \
    add-apt-repository -y 'ppa:deadsnakes/ppa' && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
        python"${PYTHON_VERSION}" \
        python"${PYTHON_VERSION}"-venv \
        binutils \
        binfmt-support && \
    apt-get -qq -y install --no-install-recommends \
        vim \
        emacs && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user "docker" with uid 1000
RUN adduser \
      --shell /bin/bash \
      --gecos "default user" \
      --uid 1000 \
      --disabled-password \
      docker && \
    chown -R docker /home/docker && \
    mkdir -p /home/docker/work && \
    chown -R docker /home/docker/work && \
    mkdir /work && \
    chown -R docker /work && \
    chmod -R 777 /work && \
    mkdir /docker && \
    printf '#!/bin/bash\n\njupyter lab --no-browser --ip 0.0.0.0 --port 8888\n' > /docker/entrypoint.sh && \
    chown -R docker /docker && \
    printf '\nexport PATH=/usr/local/venv/bin:"${PATH}"\n' >> /root/.bashrc && \
    cp /root/.bashrc /etc/.bashrc && \
    echo 'if [ -f /etc/.bashrc ]; then . /etc/.bashrc; fi' >> /etc/profile && \
    echo "SHELL=/bin/bash" >> /etc/environment

# Use C.UTF-8 locale to avoid issues with ASCII encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV PATH=/home/docker/.local/bin:"${PATH}"

COPY --from=builder --chown=docker --chmod=777 /usr/local/venv /usr/local/venv

USER docker

WORKDIR /home/docker
ARG WOLFRAM_ID
ARG WOLFRAM_PASSWORD
RUN git clone https://github.com/WolframResearch/WolframLanguageForJupyter && \
    cd WolframLanguageForJupyter/ && \
    wolframscript \
        -activate \
        -username "${WOLFRAM_ID}" \
        -password "${WOLFRAM_PASSWORD}" && \
    wolframscript -activate && \
    ./configure-jupyter.wls add

ENV USER ${USER}
ENV HOME /home/docker
WORKDIR ${HOME}/work

ENV PATH=${HOME}/.local/bin:${PATH}

# Run with login shell to trigger /etc/profile
# c.f. https://youngstone89.medium.com/unix-introduction-bash-startup-files-loading-order-562543ac12e9
ENTRYPOINT ["/bin/bash", "-l"]

CMD ["/docker/entrypoint.sh"]
