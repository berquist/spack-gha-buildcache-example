#!/bin/bash

set -euo pipefail

name=local
loc="${HOME}"/spack-mirror
spec="git@2.41.0%gcc@8.5.0"

# Only do this once.
# spack gpg init
# spack gpg create "Eric Berquist" "hello@world.com"

# The mirror may already exist, and there's no --force
spack mirror add "${name}" "${loc}" || true
spack buildcache push --rebuild-index "${name}" "${spec}"
# Only defined in the env spack.yaml
# spack buildcache push --rebuild-index personal-github "${spec}"
