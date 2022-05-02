include Makefile.defs

REGISTER ?= ghcr.io
GIT_REPO ?= spidernet-io/netknife
FINAL_IMAGES := ${REGISTER}/${GIT_REPO}/netknife
BASE_IMAGES := ${REGISTER}/${GIT_REPO}/netknife-base

.PHONY: build_local_image
build_local_image:
	@echo "Build Image with tag: $(GIT_COMMIT_VERSION)"
	@for i in $(FINAL_IMAGES); do \
		docker buildx build  \
				--build-arg GIT_COMMIT_VERSION=$(GIT_COMMIT_VERSION) \
				--build-arg GIT_COMMIT_TIME=$(GIT_COMMIT_TIME) \
				--build-arg VERSION=$(GIT_COMMIT_VERSION) \
				--file $(ROOT_DIR)/images/"$${i##*/}"/Dockerfile \
				--output type=docker \
				--tag $${i}:$(GIT_COMMIT_VERSION) . ; \
		echo "build success for $${i}:$(GIT_COMMIT_VERSION) " ; \
	done

.PHONY: build_local_base_image
build_local_base_image:
	@ echo "Build Image with tag: $(GIT_COMMIT_VERSION)"
	@ TAG=` git ls-tree --full-tree HEAD -- ./images/netknife-base | awk '{ print $3 }' ` ; \
		docker buildx build  \
				--build-arg GIT_COMMIT_VERSION=$(GIT_COMMIT_VERSION) \
				--build-arg GIT_COMMIT_TIME=$(GIT_COMMIT_TIME) \
				--build-arg VERSION=$(GIT_COMMIT_VERSION) \
				--file ./images/netknife-base/Dockerfile \
				--output type=docker \
				--tag $(BASE_IMAGES):$${TAG}  ./images/netknife-base ; \
		(($?==0)) || { echo "error , failed to build base image" ; exit 1 ;} ; \
		echo "build success $(BASE_IMAGES):$${TAG} "
