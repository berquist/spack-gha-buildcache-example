#!/bin/sh

set -e

spack debug report

rm -rf ._my_view || true
rm my_view || true

spack concretize --force --fresh
spack install --fail-fast
spack -d buildcache push --rebuild-index --force github-container-registry
