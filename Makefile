include Makefile.defs

BIN_SUBDIRS := cmd/tornado


.PHONY: all build-bin
all: build-bin
build-bin:
	@ mkdir -p $(DESTDIR_BIN)
	@ for ITEM in $(BIN_SUBDIRS); do \
  		BIN_NAME="$${ITEM##*/}" ; \
  		rm -f $(DESTDIR_BIN)/$${BIN_NAME} ; \
  		$(GO_BUILD) -o $(DESTDIR_BIN)/$${BIN_NAME}  $${ITEM}/main.go ; \
  		(($$?!=0)) && echo "error, failed to build $${ITEM}" && exit 1 ; \
  		echo "succeeded to build $${BIN_NAME} to $(DESTDIR_BIN)/$${BIN_NAME}" ; \
  	    done



# ==========================

REGISTER ?= ghcr.io
GIT_REPO ?= spidernet-io/netknife
FINAL_IMAGES := ${REGISTER}/${GIT_REPO}/netknife
BASE_IMAGES := ${REGISTER}/${GIT_REPO}/netknife-base

.PHONY: build_local_image
build_local_image:
	@echo "Build Image with tag: $(GIT_COMMIT_VERSION)"
	@for ITEM in $(FINAL_IMAGES); do \
		docker buildx build  \
				--build-arg GIT_COMMIT_VERSION=$(GIT_COMMIT_VERSION) \
				--build-arg GIT_COMMIT_TIME=$(GIT_COMMIT_TIME) \
				--build-arg VERSION=$(GIT_COMMIT_VERSION) \
				--file $(ROOT_DIR)/images/"$${ITEM##*/}"/Dockerfile \
				--output type=docker \
				--tag $${ITEM}:$(GIT_COMMIT_VERSION) . ; \
		echo "build success for $${i}:$(GIT_COMMIT_VERSION) " ; \
	done



.PHONY: build_local_base_image
build_local_base_image: IMAGEDIR := ./images/netknife-base
build_local_base_image:
	@ TAG=` git ls-tree --full-tree HEAD -- $(IMAGEDIR) | awk '{ print $$3 }' ` ; \
		echo "Build base image with tag: $${TAG}" ; \
		docker buildx build  \
				--build-arg USE_PROXY_SOURCE=true \
				--file $(IMAGEDIR)/Dockerfile \
				--output type=docker \
				--tag $(BASE_IMAGES):$${TAG}  $(IMAGEDIR) ; \
		(($$?==0)) || { echo "error , failed to build base image" ; exit 1 ;} ; \
		echo "build success $(BASE_IMAGES):$${TAG} "
