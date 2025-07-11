# Purpose

## Overview

**Purpose**: A collection of scripts to enhance and patch minimal Unix-based environments, especially for users of lightweight window managers.

### Guidelines

- Minimize use of `fork()`
- Maximum of one file
- Documentation is in comment header

### Script Types

**Environment Scripts**: Provide functionality typically handled by a full desktop environment. These scripts are POSIX-compliant and improve quality of life on minimal systems:
- [ ] Bluetooth control
- [ ] Volume control
- [ ] Backlight control
- [ ] Blue light filter
- [ ] Notification daemon

**Utilities**: General-purpose tools:
- [ ] Weatherd
- [ ] Remove duplicates
- [ ] Cloud backup
- [ ] Local backup

## Usage

Add to path without setting env var to PATH
```sh
find ~/code/scripts -type f -iname '*.sh' -exec chmod +x "{}" \;
ln -s ~/code/scripts ~/.local/bin
```
