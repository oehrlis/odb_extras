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

1. Reload OraDBA environment:

```bash
source ${ORADBA_BASE}/bin/oradba.sh
```

## Contents

- `bin/` - Executable scripts and tool wrappers
- `etc/` - Configuration files and examples
- `doc/` - Documentation
- `scripts/` - Build and maintenance scripts

## Adding New Tools

When adding new tools to this extension:

### For Users (Installed Extension)

After installing the extension, you can add your own tools:

```bash
cd ${ORADBA_LOCAL_BASE}/odb_extras

# Add your tool
cp /path/to/my_tool bin/
chmod +x bin/my_tool

# Update checksums
./bin/oradba_checksum.sh

# Verify
./bin/oradba_checksum.sh --verify
```

### For Developers

1. Add your tool wrapper script to `bin/`
2. Make it executable: `chmod +x bin/your_tool.sh`
3. Update checksums: `./scripts/checksum.sh update`
4. Test: `make test`
5. Document in `doc/`

See [doc/checksums.md](doc/checksums.md) for complete details on checksum
management for both users and developers.

## Configuration

Configuration files can be placed in `etc/` directory. See individual tool documentation in `doc/` for details.

## Requirements

- OraDBA v0.19.0 or later
- Bash 4.0 or later

## License

Apache License Version 2.0

## Author

Stefan Oehrli (oes) <stefan.oehrli@oradba.ch>
