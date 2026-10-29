# Docker image

This repo includes a docker image for running the bats tests in the CI.

## Running the image

```bash
./drun.sh
cd test
bats .
```

## Updating the image

```bash
docker compose build
docker compose push
```
