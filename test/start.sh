#!/usr/bin/env bash
docker run -it -v "$(cd $(dirname $0)/..; pwd):/code" bats/bats:latest "$@"