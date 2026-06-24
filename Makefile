# Build OCI images locally with melange + apko, run through Docker.
# The only host dependency is Docker — the toolchain comes from the official
# Chainguard images, so nothing needs to be installed locally.

IMAGE ?= dbug
TAG   ?= latest
ARCH  ?= $(shell uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')

DOCKER        ?= docker
MELANGE_IMAGE ?= cgr.dev/chainguard/melange:latest
APKO_IMAGE    ?= cgr.dev/chainguard/apko:latest

DIR     := oci/$(IMAGE)
WORK    := $(abspath $(DIR))
# All build artifacts go under oci/$(IMAGE)/out. OUT is the path as seen from
# inside the build containers (mounted at /work); OUTDIR is the host path.
OUT     := out
OUTDIR  := $(DIR)/$(OUT)
KEY     := $(OUTDIR)/melange.rsa
PKGDIR  := $(OUTDIR)/packages
TARBALL := $(OUTDIR)/$(IMAGE).tar
REF     := $(IMAGE):$(TAG)
# apko appends the arch to the tag when loading a single-arch tarball,
# so the image `docker load` produces is REF-ARCH, not REF.
LOADREF := $(REF)-$(ARCH)

# melange needs --privileged for its sandboxed build runner; apko does not.
MELANGE := $(DOCKER) run --rm --privileged -v "$(WORK)":/work -w /work $(MELANGE_IMAGE)
APKO    := $(DOCKER) run --rm -v "$(WORK)":/work -w /work $(APKO_IMAGE)

.DEFAULT_GOAL := build
.PHONY: build load run packages key sizes submodules lint clean help

$(OUTDIR):
	mkdir -p $(OUTDIR)

# Materialize vendored submodules (dbug copies its tldr-pages cheatsheets from
# oci/dbug/vendor/tldr). No-op when nothing is vendored or already checked out.
submodules:
	git submodule update --init --recursive

key: $(KEY)
$(KEY): | $(OUTDIR)
	$(MELANGE) keygen $(OUT)/melange.rsa

packages: key submodules | $(OUTDIR)
	$(MELANGE) build melange.yaml \
		--arch $(ARCH) \
		--signing-key $(OUT)/melange.rsa \
		--out-dir $(OUT)/packages

build: packages | $(OUTDIR)
	$(APKO) build \
		--arch $(ARCH) \
		--keyring-append $(OUT)/melange.rsa.pub \
		--sbom-path $(OUT) \
		apko.yaml $(REF) $(OUT)/$(IMAGE).tar

load: build
	$(DOCKER) load < $(TARBALL)

run: load
	$(DOCKER) run --rm -it $(LOADREF)

sizes:
	IMAGE=$(IMAGE) TAG=$(TAG) ARCH=$(ARCH) DOCKER=$(DOCKER) ./scripts/image-sizes.sh

# Verify every command in oci/$(IMAGE)/pages/*.md resolves to an installed
# package or a dotfiles function/abbr. Pure shell, no build needed.
lint:
	$(DIR)/lint-recipes.sh

clean:
	rm -rf $(OUTDIR)

help:
	@echo "Targets: build (default), load, run, packages, key, sizes, lint, clean"
	@echo "Vars:    IMAGE=$(IMAGE) TAG=$(TAG) ARCH=$(ARCH)"
