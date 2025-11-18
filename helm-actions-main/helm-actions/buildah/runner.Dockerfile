# runner.Dockerfile
FROM quay.io/buildah/stable:v1.42

ARG ACT_RUNNER_VERSION=0.2.13

# Need root to install packages and act_runner
USER root

# Optional but helpful: install 'which' for debugging
RUN dnf -y install which shadow-utils && \
    dnf clean all

# Ensure /etc/subuid / /etc/subgid exist, and set mapping for user 'build'
RUN touch /etc/subuid /etc/subgid && \
    chmod g=u /etc/subuid /etc/subgid /etc/passwd && \
    echo build:10000:65536 > /etc/subuid && \
    echo build:10000:65536 > /etc/subgid

# /data will be the working dir for act_runner
RUN mkdir -p /data && chown build:build /data

# Switch to the 'build' user (already present in base image)
USER build
ENV HOME=/home/build

# Rootless Buildah config in $HOME
RUN mkdir -p ${HOME}/.config/containers && \
    printf '[storage]\ndriver = "vfs"\n' > ${HOME}/.config/containers/storage.conf

# Back to root briefly to install act_runner & entrypoint
USER root
RUN curl -L -o /usr/local/bin/act_runner \
    https://dl.gitea.com/act_runner/${ACT_RUNNER_VERSION}/act_runner-${ACT_RUNNER_VERSION}-linux-amd64 && \
    chmod +x /usr/local/bin/act_runner

# Copy the entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Final runtime: non-root 'build'
USER build
WORKDIR /data

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
