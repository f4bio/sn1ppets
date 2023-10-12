# landingpage-vite

> _a basic term-like start page with tree structure_

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [generate ascii image](#generate-ascii-image)
- [dev](#dev)
  - [dev run](#dev-run)
- [prod](#prod)
  - [docker build](#docker-build)
  - [docker push](#docker-push)
  - [docker run](#docker-run)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## generate ascii image

`$ jp2a --width=64 src/profile.jpg`

## dev

### dev run

`$ npm run dev`

## prod

### docker build

```bash
docker build \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg BUILD_VERSION="2.0.0" \
  --file Dockerfile \
  --tag [registry.digitalocean.com/]f4bio/landingpage:latest \
  --no-cache \
  .
```

### docker push

`$ docker push [registry.digitalocean.com/]f4bio/landingpage:latest`

### docker run

`$ docker run --rm [registry.digitalocean.com/]f4bio/landingpage:latest`
