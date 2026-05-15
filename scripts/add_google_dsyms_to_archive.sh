#!/bin/sh

set -eu

archive_path="${1:-${ARCHIVE_PATH:-}}"

if [ -z "${archive_path}" ]; then
    echo "error: Archive path not provided. Pass the .xcarchive path as the first argument." >&2
    exit 1
fi

if [ ! -d "${archive_path}" ]; then
    echo "error: Archive not found: ${archive_path}" >&2
    exit 1
fi

app_path="$(find "${archive_path}/Products/Applications" -maxdepth 1 -type d -name "*.app" | head -n 1)"

if [ -z "${app_path}" ]; then
    echo "error: Could not find app inside archive: ${archive_path}" >&2
    exit 1
fi

frameworks_path="${app_path}/Frameworks"

if [ ! -d "${frameworks_path}" ]; then
    echo "No embedded frameworks found in archive."
    exit 0
fi

mkdir -p "${archive_path}/dSYMs"

find "${frameworks_path}" -maxdepth 1 -type d -name "*.framework" | sort | while IFS= read -r framework_path; do
    framework="$(basename "${framework_path}" .framework)"
    binary="${framework_path}/${framework}"
    dsym_path="${archive_path}/dSYMs/${framework}.framework.dSYM"

    if [ ! -f "${binary}" ]; then
        echo "Skipping ${framework}.framework: binary not found."
        continue
    fi

    dsymutil "${binary}" -o "${dsym_path}" 2>/dev/null || true

    binary_uuid="$(dwarfdump --uuid "${binary}" | awk '{print $2}' | head -n 1)"
    dsym_uuid="$(dwarfdump --uuid "${dsym_path}" | awk '{print $2}' | head -n 1)"

    if [ -z "${binary_uuid}" ]; then
        echo "Skipping ${framework}.framework: UUID not found."
        continue
    fi

    if [ "${binary_uuid}" != "${dsym_uuid}" ]; then
        echo "error: ${framework} dSYM UUID mismatch. Binary=${binary_uuid} dSYM=${dsym_uuid}" >&2
        exit 1
    fi

    echo "Added ${framework}.framework.dSYM (${dsym_uuid})"
done
