MAJOR_MINOR=5.2
PATCH_VERSION=1
CUR_DATE=$(shell date +%Y-%m-%d)
IMAGE=us-docker.pkg.dev/jarvice/images/blender:$(MAJOR_MINOR).$(PATCH_VERSION)-$(CUR_DATE)
IMAGE-test-8=us-docker.pkg.dev/jarvice/images/blender:rocky-test-8-$(MAJOR_MINOR).$(PATCH_VERSION)-$(CUR_DATE)
IMAGE-test-9=us-docker.pkg.dev/jarvice/images/blender:rocky-test-9-$(MAJOR_MINOR).$(PATCH_VERSION)-$(CUR_DATE)
SERIAL_NUMBER=$(CUR_DATE).1000

all:
	docker build \
		--pull \
		--rm \
		-f "Dockerfile.rocky" \
		--build-arg MAJOR_MINOR=$(MAJOR_MINOR) \
		--build-arg PATCH_VERSION=$(PATCH_VERSION) \
		--build-arg SERIAL_NUMBER=$(SERIAL_NUMBER) \
		-t $(IMAGE) "."

push: all
	docker push $(IMAGE)

test-8:
	docker build \
		--pull \
		--rm \
		-f "Dockerfile.rocky8" \
		--build-arg MAJOR_MINOR=$(MAJOR_MINOR) \
		--build-arg PATCH_VERSION=$(PATCH_VERSION) \
		--build-arg SERIAL_NUMBER=$(SERIAL_NUMBER) \
		-t $(IMAGE-test-8) "."

test-9:
	docker build \
		--pull \
		--rm \
		-f "Dockerfile.rocky9" \
		--build-arg MAJOR_MINOR=$(MAJOR_MINOR) \
		--build-arg PATCH_VERSION=$(PATCH_VERSION) \
		--build-arg SERIAL_NUMBER=$(SERIAL_NUMBER) \
		-t $(IMAGE-test-9) "."

push-test-8: test-8
	docker push $(IMAGE-test-8)

push-test-9: test-9
	docker push $(IMAGE-test-9)
