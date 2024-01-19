#!/bin/bash

set -e
set -x

# deps:
#  - git

if command -v apt-get; then
    apt-get install -y --no-install-recommends \
            git
elif command -v yum; then
    yum install \
        git
elif command -v brew; then
    brew install \
         git
fi
