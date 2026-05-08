# containers/dev/Dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        bash zsh tmux \
        build-essential libssl-dev libffi-dev zlib1g-dev libreadline-dev \
        libsqlite3-dev libbz2-dev libncurses-dev liblzma-dev xz-utils \
        tk-dev uuid-dev \
        curl ca-certificates git gnupg unzip less sudo \
        ripgrep fd-find fzf jq bat eza btop \
    && rm -rf /var/lib/apt/lists/* \
    # Ubuntu renames bat->batcat and fd-find->fdfind. Symlink to the canonical
    # names users expect, and tolerate either naming if the upstream package
    # changes in the future.
    && for src_dst in batcat:bat bat:bat fdfind:fd fd:fd; do \
            src="${src_dst%%:*}"; dst="${src_dst##*:}"; \
            if [ -e "/usr/bin/$src" ] && [ ! -e "/usr/local/bin/$dst" ]; then \
                ln -sf "/usr/bin/$src" "/usr/local/bin/$dst"; \
            fi; \
        done

# Ubuntu 24.04 base image ships a default `ubuntu` user/group at UID/GID 1000.
# Remove it first so we can claim 1000 for `dev` (matches host UID for bind mount ownership).
RUN userdel -r ubuntu 2>/dev/null || true \
    && groupdel ubuntu 2>/dev/null || true \
    && groupadd -g 1000 dev \
    && useradd -m -u 1000 -g 1000 -s /bin/bash dev \
    && echo 'dev ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dev

USER dev
WORKDIR /home/dev

RUN curl -fsSL https://mise.run | sh

ENV PATH="/home/dev/.local/share/mise/shims:/home/dev/.local/bin:${PATH}"

RUN /home/dev/.local/bin/mise use -g node@lts starship rust@stable

COPY --chown=dev:dev entrypoint.sh /home/dev/entrypoint.sh
RUN chmod +x /home/dev/entrypoint.sh

WORKDIR /workspace
ENTRYPOINT ["/home/dev/entrypoint.sh"]
