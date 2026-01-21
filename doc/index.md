# OraDBA Extras Extension Documentation

## Overview

The OraDBA Extras extension provides shell wrappers and configurations for user-specific tools that may not be available in the standard OS installation.

## Tools Included

### GNU tar

Enhanced tar command with additional features not available in BSD tar (macOS default).

### OCI CLI

Oracle Cloud Infrastructure command-line interface wrapper with user-specific configurations.

### jq

JSON processor for command-line JSON manipulation.

## Adding New Tools

To add a new tool to this extension:

1. Create wrapper script in `bin/`
2. Add configuration example in `etc/` (if needed)
3. Document the tool in this directory

## Configuration

Place configuration files in `etc/` directory. Tool-specific configurations should use the pattern:

- `etc/<toolname>.conf` - Main configuration
- `etc/<toolname>.conf.example` - Example configuration

## Usage

Once installed, all toOnce installed, all toOnce installed, all toOnce installed, all toOnce installed, all xaOnce installed, all toOnce installed, sioOnce instasion
```
