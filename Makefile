VERSION     ?= $(shell git describe --tags --long)
IMAGE_BASE         = ottoyiu/cfs-cpu-burn
IMAGE_BUILD_FQ     = $(IMAGE_BASE):$(VERSION)

.PHONY: image push

image:
	docker build -t $(IMAGE_BUILD_FQ) .

push:
	docker push $(IMAGE_BUILD_FQ)

target/cmd:
	mkdir -p $@

target/cmd/%: target/cmd
	CGO_ENABLED=0 GOOS=linux go build -tags netgo -o $@ cmd/$*/*.go
