# UmbrArch

UmbrArch is an opinionated Arch Linux setup influenced technically by [omarchy](https://github.com/basecamp/omarchy).

## Usage

Install UmbrArch on a fresh Arch Linux installation:

```bash
curl -fsSL https://raw.githubusercontent.com/tuukkateppola/umbrarch/master/boot.sh | bash
```

### Dry Run

You can preview the installation without making any changes by enabling dry-run mode. This is useful to see exactly what commands would be executed.

```bash
# Run in dry-run mode (simulates changes)
curl -fsSL https://raw.githubusercontent.com/tuukkateppola/umbrarch/master/boot.sh | UMBRARCH_DRY_RUN=true bash

# Run the actual installation when ready
curl -fsSL https://raw.githubusercontent.com/tuukkateppola/umbrarch/master/boot.sh | bash
```

### What Gets Installed

See `install/targets/default.sh` for the complete list of packages and features.

## License

UmbrArch is released under the [MIT License](https://opensource.org/licenses/MIT).
