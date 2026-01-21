# OraDBA Extras Extension

OraDBA extension providing user-specific tools and utilities that are not available in the standard OS installation.

## Overview

This extension provides shell wrappers and configurations for various tools:

- **GNU tar** - Enhanced tar command
- **OCI CLI** - Oracle Cloud Infrastructure command-line interface
- **jq** - JSON processor
- Additional user-specific utilities

## Installation

1. Copy the extension to your OraDBA local extensions directory:

```bash
cp -R odb_extras ${ORADBA_LOCAL_BASE}/
```

2. Reload OraDBA environment:

```bash
source ${ORADBA_BASE}/bin/oradba.sh
```

## Contents

- `bin/` - Executable scripts and tool wrappers
- `etc/` - Configuration files and examples
- `doc/` - Documentation

## Configuration

Configuration files can be placed in `etc/` directory. See individual tool documentation in `doc/` for details.

## Requirements

- OraDBA v0.19.0 or later
- Bash 4.0 or later

## License

Apache License Version 2.0

## Author

Stefan Oehrli (oes) stefan.oehrli@oradba.ch
