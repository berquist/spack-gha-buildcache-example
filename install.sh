#!/bin/sh

spack concretize --force --fresh
spack install --fail-fast
spack buildcache push --force local-buildcache
