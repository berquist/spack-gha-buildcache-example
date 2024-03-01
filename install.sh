#!/bin/sh

set -e

mirror_name="${1}"

spack debug report

rm -rf ._my_view || true
rm my_view || true

spack concretize --force --fresh
spack install --fail-fast
spack buildcache push --rebuild-index --force "${mirror_name}"
