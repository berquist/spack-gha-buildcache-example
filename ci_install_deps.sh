#!/bin/bash

set -e
set -x

if command -v apt-get; then
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y --no-install-recommends \
            bzip2 \
            ca-certificates \
            file \
            g++ \
            gcc \
            git \
            make \
            patch \
            python3 \
            unzip \
            xz-utils
elif command -v dnf; then
    dnf upgrade -y --allowerasing
    dnf install -y --allowerasing \
        bzip2 \
        file \
        gcc \
        gcc-c++ \
        git \
        make \
        patch \
        unzip \
        xz
elif command -v brew; then
    brew upgrade
    brew install \
         git
fi
