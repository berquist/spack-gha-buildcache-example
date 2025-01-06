#!/bin/sh

# curl_index_spack.sh: A simple check for showing that an OCI buildcache has
# at least one Spack package inside.

curl \
    -H "Authorization: Bearer null" \
    -H "Accept: application/vnd.docker.distribution.manifest.v2+json,application/vnd.oci.image.manifest.v1+json" \
    -s \
    https://ghcr.io/v2/berquist/spack-gha-buildcache-example/manifests/index.spack
