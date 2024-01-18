#!/bin/sh

curl \
    -H "Authorization: Bearer null" \
    -H "Accept: application/vnd.docker.distribution.manifest.v2+json,application/vnd.oci.image.manifest.v1+json" \
    -s \
    https://ghcr.io/v2/berquist/spack-gha-buildcache-example/manifests/index.spack
