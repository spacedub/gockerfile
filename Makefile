GATEWAY_IMAGE := po3rin/gocker
IMAGE := po3rin/gockersample

GATEWAY_IMAGE_TEST := po3rin/gocker-t

.PHONY: debug-llb
debug-raw:
	go run cmd/gocker/main.go -graph | buildctl debug dump-llb | jq .

.PHONY: debug-img
debug-img:
	go run cmd/gocker/main.go -graph | buildctl debug dump-llb --dot | dot -T png -o out.png

# TODO debug.
# error: failed to solve: rpc error: code = Unknown desc = runtime execution on platform darwin/amd64 not supported
.PHONY: build-gocker
build-gocker:
	go run cmd/gocker/main.go -graph | buildctl build --output type=docker,name=gockersample | docker load

.PHONY: build-buildctl
build-buildctl:
	buildctl build \
		--frontend=gateway.v0 \
		--frontend-opt=source=$(GATEWAY_IMAGE) \
		--local gockerfile=. \
		--local context=. \
		--output type=docker,name=$(IMAGE) | docker load

.PHONY: build-buildctl-test
build-buildctl-test:
	buildctl build \
		--frontend=gateway.v0 \
		--frontend-opt=source=$(GATEWAY_IMAGE_TEST) \
		--local gockerfile=. \
		--local context=. \
		--exporter=docker \
		--output type=docker,name=$(IMAGE) | docker load

.PHONY: image
image:
	docker build . -t $(GATEWAY_IMAGE) && docker push $(GATEWAY_IMAGE)

.PHONY: run
run:
	docker run -it -p 8080:8080 po3rin/gockersample:latest /bin/server

.PHONY: image-test
image-test:
	docker build . -t $(GATEWAY_IMAGE_TEST) && docker push $(GATEWAY_IMAGE_TEST)

.PHONY: run-test
run-test:
	docker run -it -p 8080:8080 po3rin/gockersample:latest /bin/server
