all:
	DOCKER_BUILDKIT=1 docker build --pull --rm -f "Dockerfile" -t us-docker.pkg.dev/jarvice/images/blender:4.0.0 "."

push: all
	docker push us-docker.pkg.dev/jarvice/images/blender:4.0.0
