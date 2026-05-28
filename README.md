# Antigravity CLI (agy) - Docker Distribution

This repository contains the configuration to build a Docker image that bundles the `agy` (Google Antigravity CLI) binary for all supported platforms, and a GitHub Actions workflow to build and push the image daily to GitHub Packages.

## Features

- **Multi-Platform Bundling:** The Docker image contains `agy` binaries for:
  - macOS Apple Silicon (`darwin-arm64/agy`)
  - macOS Intel (`darwin-amd64/agy`)
  - Linux Intel (`linux-amd64/agy`)
  - Linux ARM64 (`linux-arm64/agy`)
  - Windows (`windows-amd64/agy.exe`)
- **Automated Daily Updates:** Built-in GitHub Actions workflow runs every night to fetch the latest version of `agy` and push updated images to GHCR.
- **Easy Extraction:** Designed as a distribution package, the container automatically copies all binaries to your local directory when run with a volume mount.

## Usage

### Extracting Binaries

To extract the `agy` binaries for all platforms to a directory on your host machine, run:

```bash
docker run --rm -v $(pwd)/binaries:/target ghcr.io/<owner>/agy:latest
```

This will create a `binaries/` directory with the following structure:
```text
binaries/
├── darwin-amd64/
│   └── agy
├── darwin-arm64/
│   └── agy
├── linux-amd64/
│   └── agy
├── linux-arm64/
│   └── agy
└── windows-amd64/
    └── agy.exe
```

You can then copy the appropriate binary for your system (e.g. `binaries/darwin-arm64/agy` for macOS Apple Silicon) to your system path:

```bash
cp binaries/darwin-arm64/agy ~/.local/bin/agy
```

## Repository Structure

- `Dockerfile`: Sets up a Debian builder stage to download and verify checksums for all platforms, then copies them to a minimal Alpine base image.
- `entrypoint.sh`: A helper script that checks for a `/target` volume mount and copies the binaries out.
- `.github/workflows/deploy.yml`: Daily CI/CD build and publish workflow.
# agy-bundle
