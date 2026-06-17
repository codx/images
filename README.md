# images

OCI container images built with [apko](https://github.com/chainguard-dev/apko)
and [melange](https://github.com/chainguard-dev/melange).

## Images

| Image                  | Description                                   |
| ---------------------- | --------------------------------------------- |
| [dbug](./oci/dbug)     | Network debugging & troubleshooting container |

## Build

The [`Makefile`](./Makefile) builds for the host architecture. The only
dependency is **Docker** — `apko` and `melange` run from the official Chainguard
images, so nothing needs to be installed locally.

```bash
make build           # build the image into a loadable tarball (default)
make load            # build, then `docker load`
make run             # build, load, then run interactively
make sizes           # list installed packages by size, largest first
make clean

# Override the image, tag, or arch:
make build IMAGE=dbug TAG=latest ARCH=arm64
```

Images are built multi-arch (`amd64`, `arm64`) and pushed by the GitHub Actions
workflow.

## Adding an image

1. Create `./oci/<name>/apko.yaml` listing the Alpine `packages` to install plus
   the `entrypoint`/`environment`.
2. Add any generated files (dotfiles, config) as a local `melange.yaml` package
   referenced via `@local ./packages`.
3. Add a `.github/workflows/<name>.yml` (copy `dbug.yml`) to build and push it.
