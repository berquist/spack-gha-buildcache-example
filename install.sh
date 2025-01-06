#!/bin/sh

set -e

mirror_name="${1}"

spack debug report

rm -rf ._my_view || true
rm my_view || true

spack concretize --force --fresh
spack install --fail-fast
# See https://github.com/spack/spack/pull/42423 for information on the below.
# This is no longer necessary if pushing each package after build is enabled.
# spack buildcache push --rebuild-index --force "${mirror_name}"
# I'm not sure this is strictly necessary.
# spack buildcache update-index "${mirror_name}"
