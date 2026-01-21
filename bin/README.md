# Bin Directory

Place executable scripts and tool wrappers in this directory.

## Naming Convention

- Use descriptive lowercase names with hyphens: `my-tool.sh`
- Make scripts executable: `chmod +x my-tool.sh`
- Use shebang: `#!/usr/bin/env bash`

## Examples

```bash
# Create a wrapper for gnu-tar
cat > gnu-tar << 'SCRIPT'
#!/usr/bin/env bash
exec /usr/local/bin/gtar "$@"
SCRIPT
chmod +x gnu-tar

# Create a wrapper for oci with custom config
cat > oci << 'SCRIPT'
#!/usr/bin/env bash
export OCI_CLI_CONFIG_FILE="${HOME}/.oci/config"
exec /usr/local/bin/oci "$@"
SCRIPT
chmod +x oci
```

## Best Practices

- Keep scripts simple - just wrappers
- Use environment variables for configuration
- Avoid hardcoded paths when possible
- Document usage in `doc/` directory
