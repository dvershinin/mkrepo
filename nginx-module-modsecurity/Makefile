all: build

export ITERATION := $(shell git log --oneline . 2>/dev/null | awk 'END {print NR}')

build:
	docker run \
		--rm \
		-ti \
		-e ITERATION \
		-v "$(shell pwd):/tmp/fpmbuild" \
		mkubenka/fpm-centos7 \
		./build.sh

.PHONY: all build
