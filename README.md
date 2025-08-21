<!--Author: D.A.Pelasgus-->
<p align="center"><img src="assets/logo.svg" alt="ChimeraOS" style="width: 150px;" /></p>

[![status](https://img.shields.io/badge/status-stable-%23961937.svg?style=for-the-badge)](https://github.com/chimeraos/install-media/releases/latest)
[![License](https://img.shields.io/badge/License-MIT-%23961937.svg?style=for-the-badge)](https://github.com/ChimeraOS/chimeraos/blob/master/LICENSE)
[![Chat Server](https://img.shields.io/badge/chat-discord-%23961937.svg?style=for-the-badge)](https://discord.gg/fKsUbrt)
[![website](https://img.shields.io/badge/website-chimeraos.org-%23961937.svg?style=for-the-badge)](https://chimeraos.org)
[![Made with Love](https://img.shields.io/badge/made_with-❤-%23961937.svg?style=for-the-badge)](https://chimeraos.org)

Bringing the console experience to pc.

> [!CAUTION]
> DO NOT DOWNLOAD DIRECTLY FROM THE RELEASES PAGE.
> THIS IS NOT INSTALLATION MEDIA.

> [!IMPORTANT]
> To download use the following link:
> [ChimeraOS website](https://chimeraos.org)

> [!NOTE]
> Instantly turn any PC into a gaming console.
> 
> Thousands of games, dozens of platforms.
> 
> Fully controller compatible interface.
> 
> Automatic updates that stay out of the way.

## This fork: AMD-optimized build (RX 7900 XTX)

- Target: All-AMD systems; unnecessary Intel and NVIDIA packages removed from the manifest to reduce dependencies and image size.
- AMD overclock for RX 7900 XTX: 2550 MHz max boost clock and 370 W power limit.
- Applied automatically on every boot:
  - Kernel parameter enabling OC features: `amdgpu.ppfeaturemask=0xffffffff` in `rootfs/usr/lib/frzr.d/bootconfig.conf`.
  - Systemd service `amd-oc.service` runs `/usr/bin/apply-amd-oc.sh` to set power cap and boost clock.
- These customizations persist across updates when you build and install images produced from this repository.

Tuning values
- Edit `rootfs/usr/bin/apply-amd-oc.sh` and change the `POWER_W` and `BOOST_MHZ` values to suit your GPU/cooling.
- Rebuild the image to apply the new defaults.
- Use at your own risk. Ensure your PSU/cooling can handle the configured power and clocks.

Building this fork
- Use `build-image.sh` (run as root on an Arch-based host) to produce an image. Output is placed under `output/`.
- Adjust versions and package selections in `manifest` as needed.
