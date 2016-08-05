all: build

build:
	docker run \
		--rm \
		-ti \
		-e ITERATION \
		-v "$(shell pwd):/tmp/fpmbuild" \
		mkubenka/fpm-centos7 \
		./build.sh

.PHONY: all build
