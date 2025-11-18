#!/bin/sh
set -e

# Determine the current UID/GID inside the container
uid="$(id -u)"
gid="$(id -g)"

# Create a private runtime dir for this UID
runtime_dir="/tmp/run-$uid"
mkdir -p "$runtime_dir"
chown "$uid:$gid" "$runtime_dir" 2>/dev/null || true
chmod 700 "$runtime_dir"

# Export Buildah-friendly environment
export XDG_RUNTIME_DIR="$runtime_dir"
export STORAGE_DRIVER="${STORAGE_DRIVER:-vfs}"
export BUILDAH_ISOLATION="${BUILDAH_ISOLATION:-chroot}"
export BUILDAH_FORMAT="${BUILDAH_FORMAT:-docker}"

# Optional: sanity debug (comment out if noisy)
echo "Using XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR for uid=$uid"

exec /usr/local/bin/act_runner "$@"
