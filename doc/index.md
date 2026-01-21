# OraDBA Extras Extension Documentation

## Overview

The OraDBA Extras extension provides shell wrappers and configurations for
user-specific tools that may not be available in the standard OS installation.

## Tools Included

### GNU tar

Enhanced tar command with additional features not available in BSD tar (macOS default).

### OCI CLI

Oracle Cloud Infrastructure command-line interface wrapper with user-specific
configurations.

### jq

JSON processor for command-line JSON manipulation.

## Adding New Tools

When adding new tools to this extension:

### As a User (Adding to Installed Extension)

1. Download or copy your tool to the extension's `bin/` directory
2. Make it executable: `chmod +x bin/your_tool`
3. Update checksums: `./bin/oradba_checksum.sh`
4. Verify: `./bin/oradba_checksum.sh --verify`

Example:

```bash
cd ${ORADBA_LOCAL_BASE}/odb_extras
wget https://example.com/tool -O bin/my_tool
chmod +x bin/my_tool
./bin/oradba_checksum.sh
```

### As a Developer (During Development)

1. Add the tool wrapper to `bin/`
2. Add configuration examples to `etc/` (if needed)
3. Update checksums: `./scripts/checksum.sh update`
4. Test the tool integration
5. Update this documentation

See [Checksum Management](checksums.md) for complete details on maintaining
file integrity and handling binary tools.

## Configuration

Place configuration files in `etc/` directory. Tool-specific configurations should use the pattern:

- `etc/<toolname>.conf` - Main configuration
- `etc/<toolname>.conf.example` - Example configuration

## Usage

Once installed, all tools are available in your PATH through OraDBA's
environment management.

```bash
# Example usage of GNU tar
gtar -czf archive.tar.gz directory/

# Example usage of jq
echo '{"name":"test"}' | jq .name
```

## Documentation

- [Checksum Management](checksums.md) - Managing file integrity and checksums
