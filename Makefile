all:
	podman build --pull --rm -f "Dockerfile" -t us-docker.pkg.dev/jarvice/images/blender:4.0.2 "."

push:
	podman push us-docker.pkg.dev/jarvice/images/blender:4.0.2
