# Checksum Management

## Overview

OraDBA extensions use checksums to ensure file integrity. The
`.extension.checksum` file contains SHA-256 checksums for all tracked files
in the extension. This helps detect unauthorized modifications or corruption.

## Quick Reference

### For Installed Extensions (Users)

When you add tools to an installed extension:

```bash
# After adding new tools/binaries to your extension
cd ${ORADBA_LOCAL_BASE}/odb_extras
./bin/oradba_checksum.sh

# Verify integrity
./bin/oradba_checksum.sh --verify
```

### For Development (Developers)

During extension development:

```bash
# Create initial checksum file
./scripts/checksum.sh create

# Update checksums after adding/modifying files
./scripts/checksum.sh update

# Verify file integrity
./scripts/checksum.sh verify

# List tracked files
./scripts/checksum.sh list
```

## When to Update Checksums

Update checksums whenever you:

- Add new tools or scripts to `bin/`
- Add or modify SQL scripts in `sql/`
- Add or modify RMAN scripts in `rcv/`
- Update documentation in `doc/`
- Modify configuration examples in `etc/`
- Update library files in `lib/`
- Change `VERSION`, `README.md`, `CHANGELOG.md`, or `LICENSE`

**Note**: The checksum file is automatically generated during `make build`,
but you may need to manage it manually during development.

## Workflow for Adding New Tools

### For Users (Adding Tools to Installed Extension)

When you add binary tools or scripts to your installed extension:

```bash
# Navigate to your extension
cd ${ORADBA_LOCAL_BASE}/odb_extras

# Add your tool (e.g., download a binary)
wget -O bin/my_tool https://example.com/tool
chmod +x bin/my_tool

# Update checksums to include the new file
./bin/oradba_checksum.sh
```

Output:

```text
INFO: Updating checksums in extension: /path/to/odb_extras
INFO: Backed up existing checksums to .extension.checksum.backup
SUCCESS: Updated checksums for 16 files
SUCCESS: Checksum file: /path/to/odb_extras/.extension.checksum
INFO: Changes: 1 added, 0 removed
```

Verify the update:

```bash
./bin/oradba_checksum.sh --verify
```

### For Developers (Extension Development)

During development in the repository:

1. **Add Your Tool**

   ```bash
   # Example: Add a new tool wrapper
   cp my_tool.sh bin/
   chmod +x bin/my_tool.sh
   
   # Example: Add configuration
   cp my_tool.conf.example etc/
   ```

2. **Update Checksums**

   ```bash
   ./scripts/checksum.sh update
   ```

3. **Verify Integrity**

   ```bash
   ./scripts/checksum.sh verify
   ```

   You should see:

   ```text
   INFO: Verifying file integrity...
   
   ✓ All 15 files verified successfully
   ```

## Excluding Files from Checksums

Some files should not be checksummed (logs, credentials, user configs).
Edit `.checksumignore` to exclude patterns:

```plaintext
# Exclude log files
log/
*.log

# Exclude user credentials
keystore/
secrets/
*.key
*.pem

# Exclude temporary files
tmp/
*.tmp
*.cache

# Exclude user-specific configurations
etc/*.local
```

**Default Exclusions** (always excluded):

- `.extension` - Metadata file
- `.checksumignore` - This file itself
- `.git*` - Git files
- `.extension.checksum` - The checksum file itself

## Manual Checksum Management

### Users: Managing Installed Extension Checksums

#### Update Checksums After Adding Tools

After adding new binaries or tools to your installed extension:

```bash
cd ${ORADBA_LOCAL_BASE}/odb_extras
./bin/oradba_checksum.sh
```

A backup is automatically created (`.extension.checksum.backup`).

#### Verify Extension Integrity

Check if any files have been modified or tampered with:

```bash
cd ${ORADBA_LOCAL_BASE}/odb_extras
./bin/oradba_checksum.sh --verify
```

**Success output:**

```text
INFO: Verifying checksums in: /path/to/odb_extras
SUCCESS: All 15 files verified successfully
```

**Failure output:**

```text
INFO: Verifying checksums in: /path/to/odb_extras
ERROR: MISMATCH: bin/my_tool.sh

ERROR: Verification failed: 1 errors, 14 OK
ERROR:   - 1 mismatches
INFO: Run 'oradba_checksum.sh' to update checksums
```

If verification fails:

1. If you just added/modified tools: `./bin/oradba_checksum.sh`
2. If unexpected: investigate potential corruption or tampering
3. Restore from backup if needed

### For Developers: Managing Development Checksums

#### Create Initial Checksums

When starting a new extension:

```bash
cd /path/to/extension
./scripts/checksum.sh create
```

#### Update After Changes

After modifying files or adding new tools:

```bash
./scripts/checksum.sh update
```

**Commit the updated checksum file to git if desired.**

#### Verify Integrity

Check if any files have been modified:

```bash
./scripts/checksum.sh verify
```

**Success output:**

```text
INFO: Verifying file integrity...
✓ All 15 files verified successfully
```

**Failure output:**

```text
INFO: Verifying file integrity...
ERROR: FAILED: bin/my_tool.sh (checksum mismatch)

ERROR: Verification failed: 1 errors, 14 OK
ERROR:   - 1 checksum mismatches
```

If verification fails:

1. Review what changed: `git diff`
2. If changes are intentional: `./scripts/checksum.sh update`
3. If changes are unexpected: investigate potential corruption or tampering

#### List Tracked Files

See which files are included in checksums:

```bash
./scripts/checksum.sh list
```

Output:

```text
INFO: Files tracked in checksum:

  VERSION
  README.md
  CHANGELOG.md
  LICENSE
  bin/tool1.sh
  bin/tool2.sh
  doc/index.md
  etc/config.conf.example

INFO: Total: 8 files
```

## Integration with Build Process

The checksum file is automatically managed during builds:

```bash
make build
```

The build process:

1. Generates `.extension.checksum` in the source directory
2. Includes it in the tarball
3. Removes it from source after build (not committed)

This ensures every distributed extension has integrity verification, but
developers don't need to commit checksum files to git unless desired.

## Checksum File Format

The `.extension.checksum` file format:

```text
# OraDBA Extension Checksums
# Generated: 2025-01-21T10:30:00Z
# Version: 1.0.0
#
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  VERSION
5d41402abc4b2a76b9719d911017c592  README.md
2fd4e1c67a2d28fced849ee1bb76e739  CHANGELOG.md
...
```

- Lines starting with `#` are comments
- Each line: `<SHA-256-CHECKSUM> <FILEPATH>`
- Files listed in alphabetical order

## Troubleshooting

### Command Not Found

If `./scripts/checksum.sh` is not executable:

```bash
chmod +x scripts/checksum.sh
```

### Checksum Tool Missing

The script requires either `sha256sum` (Linux) or `shasum` (macOS):

```bash
# macOS (pre-installed)
which shasum

# Linux
sudo apt-get install coreutils  # Debian/Ubuntu
sudo yum install coreutils      # RHEL/CentOS
```

### Files Not Being Tracked

If a file isn't checksummed, check if it matches a pattern in
`.checksumignore`. Use verbose mode for debugging:

```bash
./scripts/checksum.sh update --verbose
```

### Merge Conflicts in Checksum File

If you get merge conflicts in `.extension.checksum`:

```bash
# Resolve conflict by regenerating
rm .extension.checksum
./scripts/checksum.sh create
git add .extension.checksum
git commit -m "chore: Regenerate checksums after merge"
```

## Best Practices

1. **Update checksums** after every file addition/modification
2. **Verify before commits**: `./scripts/checksum.sh verify`
3. **Include in CI/CD**: Add verification to automated tests
4. **Document exclusions**: Comment why files are excluded in
   `.checksumignore`
5. **Regular verification**: Periodically verify integrity in production

## Makefile Integration

You can add checksum tasks to your Makefile:

```makefile
.PHONY: checksum-verify
checksum-verify: ## Verify file integrity
    @./scripts/checksum.sh verify

.PHONY: checksum-update
checksum-update: ## Update checksums
    @./scripts/checksum.sh update
```

Then use:

```bash
make checksum-verify
make checksum-update
```

## Security Considerations

- **Checksums detect tampering** but don't prevent it
- **Store checksums separately** for critical deployments
- **Sign releases** with GPG for cryptographic verification
- **Review changes** carefully before updating checksums
- **Audit logs** regularly if files fail verification

## Examples

### User Scenario: Adding Downloaded Tools

You want to add some tools to your installed extension:

```bash
# Navigate to your extension
cd ${ORADBA_LOCAL_BASE}/odb_extras

# Download and install tools
wget https://github.com/jqlang/jq/releases/download/jq-1.7/jq-linux64 \
     -O bin/jq
chmod +x bin/jq

# Add OCI CLI wrapper
cat > bin/oci <<'EOF'
#!/usr/bin/env bash
# OCI CLI wrapper with user config
exec /usr/local/bin/oci "$@"
EOF
chmod +x bin/oci

# Update checksums to track new files
./bin/oradba_checksum.sh
```

Output shows what changed:

```text
INFO: Updating checksums in extension: /path/to/odb_extras
INFO: Backed up existing checksums to .extension.checksum.backup
SUCCESS: Updated checksums for 18 files
SUCCESS: Checksum file: /path/to/odb_extras/.extension.checksum
INFO: Changes: 2 added, 0 removed
```

Verify everything is correct:

```bash
./bin/oradba_checksum.sh --verify
# SUCCESS: All 18 files verified successfully
```

### User Scenario: Updating an Existing Tool

You updated a tool and need to update its checksum:

```bash
cd ${ORADBA_LOCAL_BASE}/odb_extras

# Update the tool
wget https://example.com/tool-v2 -O bin/my_tool
chmod +x bin/my_tool

# Update checksums
./bin/oradba_checksum.sh
```

### Developer Scenario: Adding Multiple Tools at Once

```bash
# Add several new tools
cp tool1.sh tool2.sh tool3.sh bin/
chmod +x bin/tool*.sh

# Add configurations
cp tool1.conf.example tool2.conf.example etc/

# Update checksums
./scripts/checksum.sh update

# Verify
./scripts/checksum.sh verify
```

### Developer Scenario: Selective Exclusions

Edit `.checksumignore` to exclude user data:

```plaintext
# User-specific tool downloads (binaries may vary)
bin/downloads/
bin/cache/

# User credentials
keystore/
*.key
```

### Automated Verification in Deployment

Add to your deployment or startup script:

```bash
#!/usr/bin/env bash

# Verify extension integrity before using
if [[ -f "${ORADBA_LOCAL_BASE}/odb_extras/bin/oradba_checksum.sh" ]]; then
    if ! "${ORADBA_LOCAL_BASE}/odb_extras/bin/oradba_checksum.sh" --verify \
         >/dev/null 2>&1; then
        echo "WARNING: Extension integrity check failed!" >&2
        # Decide: exit, alert, or continue
    fi
fi

# Proceed with normal operations
```

### Monitoring Changes in Production

Create a monitoring script:

```bash
#!/usr/bin/env bash
# check_extensions.sh - Verify all extension checksums

for ext_dir in ${ORADBA_LOCAL_BASE}/*; do
    if [[ -f "${ext_dir}/.extension" ]]; then
        ext_name=$(basename "$ext_dir")
        echo "Checking: $ext_name"
        
        if [[ -x "${ext_dir}/bin/oradba_checksum.sh" ]]; then
            if ! "${ext_dir}/bin/oradba_checksum.sh" --verify 2>&1 | \
                 grep -q "SUCCESS"; then
                echo "ALERT: $ext_name has integrity issues!"
            fi
        fi
    fi
done
```

## See Also

- `.checksumignore` - Exclusion patterns (located in extension root)
- `scripts/build.sh` - Build process with checksums
- GitHub Copilot Instructions - Development standards and workflow
