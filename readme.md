# Scripts

## Overview

**Purpose**: A collection of scripts.

**Usage**
- Add to path without setting env var to PATH
```sh
find ~/code/scripts -type f -iname '*.sh' -exec chmod +x "{}" \;
ln -s ~/code/scripts ~/.local/bin
```
**Guidelines**
- Prefer builtins over calling `fork()`
- Prefer `sh` over `zsh` 
- Maximum of one file per script
- Documentation is in comment header

### Categories

#### Environment

**Role**: Patches to get the same functionality a desktop environment provides by default.

**Examples**
- `connect-bluetooth.sh`
- `adjust-volume.sh`
- `filter-bluelight.sh`

#### Automation

**Role**: Acts as a substitute to manually running commands.  

**Examples**
- `check-weather.sh`
- `remove-duplicates.sh`
- `backup-cloud.sh`
