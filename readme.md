# Description

basically, a flake for oneplus-enchilada with phosh (for now) that works on my machine™

# How to build

`NIXPKGS_ALLOW_UNFREE=1 nix build .#enchilada-fastboot-images --impure --show-trace -L`

> Note: `-L` is for printing build messages; useful when smth breaks but not necessary otherwise. Technically may slow down the build process since stdio is slow, but it's not like the process is fine as it is

# How to flash

```bash
fastboot erase dtbo
./result/flash-critical.sh
fastboot flash userdata ./result/system.img
```

> Note: Erasing the dtbo partition will make Android unbootable on the current slot [(check the pmos wiki page)](https://wiki.postmarketos.org/wiki/OnePlus_6_(oneplus-enchilada)#Pre-built_images)

