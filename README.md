# Vanillin OS Image

Vanillin OS is an operating system for servers, based on Vanilla OS.

This repo contains a [Vib][vib] recipe used to generate a Containerfile of the system.

## Build

You need the [Vib][vib] tool to generate the Containerfile.

```bash
vib build recipe.yml
podman image build -t vanillinos .
```

[vib]: https://github.com/vanilla-os/Vib

## Contributing

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)

Commit messages follow the [Conventional Commits Specification][conventional-commits]

[conventional-commits]: https://conventionalcommits.org

## Generating configuration for installer

To generate configuration for the [Albius installer][albius],
you can run the `configure-inst.sh` script, like so:

```
./configure-inst.sh install.template.json > install.conf.json
```

Alternatively, manually modify `install.template.json`

[albius]: https://github.com/Vanilla-OS/Albius

## Installing

To install Vanillin OS, for now you'll need to run a special
container with the installer from any live environment.
Pass it the device to install onto, and answer prompts to
generate installation configuration. It will begin installation
right after you answer all propmts, without any confirmations.

```
podman run --rm -ti --device /dev/sdX:/dev/vda:rwm ghcr.io/mks-h/vanillin-os-installer:main
```
