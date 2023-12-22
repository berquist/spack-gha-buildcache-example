#!/bin/sh

spack concretize --force --fresh
spack install --fail-fast
