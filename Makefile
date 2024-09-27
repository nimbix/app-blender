MAJOR_MINOR=4.2
PATCH_VERSION=2
CUR_DATE=$(shell date +%Y-%m-%d)
IMAGE=us-docker.pkg.dev/jarvice/images/blender:$(MAJOR_MINOR).$(PATCH_VERSION)-$(CUR_DATE)
SERIAL_NUMBER=$(CUR_DATE).1000
all:
	podman build \
		--pull \
		--rm \
		-f "Dockerfile.rocky" \
		--build-arg MAJOR_MINOR=$(MAJOR_MINOR) \
		--build-arg PATCH_VERSION=$(PATCH_VERSION) \
		--build-arg SERIAL_NUMBER=$(SERIAL_NUMBER) \
		-t $(IMAGE) "."

push: all
	podman push $(IMAGE)
