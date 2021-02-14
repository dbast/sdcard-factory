#!/usr/bin/env bash

set -o errtrace -o nounset -o pipefail -o errexit

docker run --rm --privileged -v /dev:/dev -v "${PWD}":/build mkaczanowski/packer-builder-arm build odroid-hc-nas.json &> build.log