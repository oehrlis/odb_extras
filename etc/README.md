# Configuration Directory

Place configuration files and examples in this directory.

## Naming Convention

- Main configs: `<toolname>.conf`
- Examples: `<toolname>.conf.example`
- Environment files: `<toolname>.env.example`

## Usage

Users should copy example files and customize:

```bash
cp <toolname>.conf.example <toolname>.conf
# Edit <toolname>.conf with user-specific settings
```

## Best Practices

- Always provide `.example` files (not tracked with user data)
- Document all configuration options
- Use sensible defaults
- Include comments explaining each option
