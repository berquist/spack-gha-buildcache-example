#!/bin/sh

spack debug report
spack concretize --force --fresh
spack install --fail-fast
spack -d buildcache push --rebuild-index --force personal-github
