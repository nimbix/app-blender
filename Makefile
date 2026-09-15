MAJOR_MINOR=5.2
PATCH_VERSION=2
CUR_DATE=$(shell date +%Y-%m-%d)
IMAGE=us-docker.pkg.dev/jarvice/images/blender:$(MAJOR_MINOR).$(PATCH_VERSION)-$(CUR_DATE)
SERIAL_NUMBER=$(CUR_DATE).1000

TEST_TARGETS := rocky8 rocky9 ubuntu20.04 ubuntu22.04 ubuntu24.04

BASE_rocky8      := rockylinux/rockylinux:8
BASE_rocky9      := rockylinux/rockylinux:9
BASE_ubuntu20.04 := ubuntu:20.04
BASE_ubuntu22.04 := ubuntu:22.04
BASE_ubuntu24.04 := ubuntu:24.04

define build-test
test-$(1):
	docker build \
		--pull \
		--rm \
		-f Dockerfile \
		--build-arg BASE_IMAGE=$$(BASE_$(1)) \
        --build-arg MAJOR_MINOR=$(MAJOR_MINOR) \
		--build-arg PATCH_VERSION=$(PATCH_VERSION) \
		--build-arg SERIAL_NUMBER=$(SERIAL_NUMBER) \
		--build-arg JARVICE_DESKTOP_BRANCH=JAR-12198-switch-from-jarvice-desktop-tigervnc-to-turbovnc \
		-t us-docker.pkg.dev/jarvice/images/blender:test-$(1)-$(MAJOR_MINOR).$(PATCH_VERSION)-$(CUR_DATE) .

push-test-$(1): test-$(1)
	docker push us-docker.pkg.dev/jarvice/images/blender:test-$(1)-$(MAJOR_MINOR).$(PATCH_VERSION)-$(CUR_DATE)
endef

# release: test-rocky9
# 	docker tag \
# 		us-docker.pkg.dev/jarvice/images/blender:test-$(1)-$(MAJOR_MINOR).$(PATCH_VERSION)-$(CUR_DATE) \
# 		us-docker.pkg.dev/jarvice/images/blender:$(MAJOR_MINOR).$(PATCH_VERSION)-$(CUR_DATE)
release:
	docker build \
		--pull \
		--rm \
		-f "Dockerfile" \
		--build-arg BASE_IMAGE=$(BASE_rocky9) \
		--build-arg MAJOR_MINOR=$(MAJOR_MINOR) \
		--build-arg PATCH_VERSION=$(PATCH_VERSION) \
		--build-arg SERIAL_NUMBER=$(SERIAL_NUMBER) \
		--build-arg JARVICE_DESKTOP_BRANCH=master \
		-t $(IMAGE) "."

$(foreach target,$(TEST_TARGETS),$(eval $(call build-test,$(target))))

.PHONY: \
	$(addprefix test-,$(TEST_TARGETS)) \
	$(addprefix push-test-,$(TEST_TARGETS))

push-release: release
	docker push $(IMAGE)
