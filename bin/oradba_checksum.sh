#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: oradba_checksum.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.01.21
# Revision...: 1.0.0
# Purpose....: Update checksums for OraDBA extension after adding tools
# Notes......: Run this after adding new tools/files to your extension
# Reference..: https://github.com/oehrlis/odb_extras
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ------------------------------------------------------------------------------

set -euo pipefail

# Script configuration
SCRIPT_NAME="$(basename "${0}")"
EXTENSION_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
readonly SCRIPT_NAME
readonly EXTENSION_DIR
readonly CHECKSUM_FILE=".extension.checksum"
readonly CHECKSUMIGNORE_FILE=".checksumignore"

# Command configuration
ACTION="update"
VERBOSE=false

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Function: show_usage
# Purpose.: Display usage information and available options
# Returns.: 0
# Output..: Usage information to stdout
# ------------------------------------------------------------------------------
show_usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Update checksums for OraDBA extension after adding or modifying files.

Options:
  -v, --verify        Verify checksums instead of updating
  --verbose           Show detailed output
  -h, --help          Show this help message

Examples:
  ${SCRIPT_NAME}                # Update checksums
  ${SCRIPT_NAME} --verify       # Verify file integrity

Description:
  This script updates the extension's checksum file after you add new
  tools or binaries. Run it whenever you:
  
  - Add new executables to bin/
  - Add new SQL scripts to sql/
  - Add new RMAN scripts to rcv/
  - Modify configuration examples in etc/
  - Update documentation in doc/

  The script automatically excludes patterns listed in .checksumignore
  (logs, temporary files, credentials, etc.)

EOF
}

# ------------------------------------------------------------------------------
# Function: log_info
# Purpose.: Log informational messages to stderr
# Args....: $@ - Message to log
# Returns.: 0
# Output..: INFO message to stderr
# ------------------------------------------------------------------------------
log_info() {
    echo "INFO: $*" >&2
}

# ------------------------------------------------------------------------------
# Function: log_success
# Purpose.: Log success messages to stderr
# Args....: $@ - Message to log
# Returns.: 0
# Output..: SUCCESS message to stderr
# ------------------------------------------------------------------------------
log_success() {
    echo "SUCCESS: $*" >&2
}

# ------------------------------------------------------------------------------
# Function: log_warning
# Purpose.: Log warning messages to stderr
# Args....: $@ - Message to log
# Returns.: 0
# Output..: WARNING message to stderr
# ------------------------------------------------------------------------------
log_warning() {
    echo "WARNING: $*" >&2
}

# ------------------------------------------------------------------------------
# Function: log_error
# Purpose.: Log error messages to stderr
# Args....: $@ - Message to log
# Returns.: 0
# Output..: ERROR message to stderr
# ------------------------------------------------------------------------------
log_error() {
    echo "ERROR: $*" >&2
}

# ------------------------------------------------------------------------------
# Function: log_verbose
# Purpose.: Log verbose messages to stderr (only if VERBOSE=true)
# Args....: $@ - Message to log
# Returns.: 0
# Output..: VERBOSE message to stderr (conditional)
# ------------------------------------------------------------------------------
log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo "VERBOSE: $*" >&2
    fi
}

# ------------------------------------------------------------------------------
# Function: checksum_cmd
# Purpose.: Generate SHA-256 checksum using available system command
# Args....: $1 - File path to checksum
# Returns.: 1 if no checksum command available, 0 otherwise
# Output..: Checksum in format: <hash> <filename>
# ------------------------------------------------------------------------------
checksum_cmd() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1"
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1"
    else
        log_error "Neither sha256sum nor shasum found"
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Function: should_exclude
# Purpose.: Check if file should be excluded from checksum based on patterns
# Args....: $1 - File path to check
# Returns.: 0 if file should be excluded, 1 otherwise
# Notes...: Checks .checksumignore patterns and built-in exclusions
# ------------------------------------------------------------------------------
should_exclude() {
    local file="$1"
    local ignore_file="${EXTENSION_DIR}/${CHECKSUMIGNORE_FILE}"
    
    # Always exclude these
    [[ "$file" == "$CHECKSUM_FILE" ]] && return 0
    [[ "$file" == ".extension" ]] && return 0
    [[ "$file" == "$CHECKSUMIGNORE_FILE" ]] && return 0
    [[ "$file" == .git* ]] && return 0
    
    # Check .checksumignore patterns
    if [[ -f "$ignore_file" ]]; then
        while IFS= read -r pattern; do
            [[ "$pattern" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${pattern// }" ]] && continue
            
            if [[ "$file" == "$pattern" ]]; then
                log_verbose "Excluding $file (matches: $pattern)"
                return 0
            fi
        done < "$ignore_file"
    fi
    
    return 1
}

# ------------------------------------------------------------------------------
# Function: get_files_to_checksum
# Purpose.: Generate list of files to include in checksums
# Returns.: 0
# Output..: Sorted list of files (one per line) to stdout
# Notes...: Excludes files matching .checksumignore patterns
# ------------------------------------------------------------------------------
get_files_to_checksum() {
    local -a files
    
    cd "${EXTENSION_DIR}" || exit 1
    
    # Directories to include
    local -a dirs=("bin" "sql" "rcv" "etc" "lib" "doc")
    local -a standalone=("VERSION" "README.md" "CHANGELOG.md" "LICENSE")
    
    # Add standalone files
    for file in "${standalone[@]}"; do
        if [[ -f "$file" ]] && ! should_exclude "$file"; then
            files+=("$file")
        fi
    done
    
    # Add directory contents
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            while IFS= read -r -d '' file; do
                if ! should_exclude "$file"; then
                    files+=("$file")
                fi
            done < <(find "$dir" -type f -print0 2>/dev/null)
        fi
    done
    
    printf '%s\n' "${files[@]}" | sort -u
}

# ------------------------------------------------------------------------------
# Function: update_checksums
# Purpose.: Update checksum file for installed extension
# Returns.: 0
# Output..: Status messages to stderr
# Notes...: Creates backup of existing checksum file
# ------------------------------------------------------------------------------
update_checksums() {
    local checksum_path="${EXTENSION_DIR}/${CHECKSUM_FILE}"
    local version
    version=$(cat "${EXTENSION_DIR}/VERSION" 2>/dev/null || echo "unknown")
    
    log_info "Updating checksums in extension: ${EXTENSION_DIR}"
    
    # Backup existing checksum file
    if [[ -f "$checksum_path" ]]; then
        cp "$checksum_path" "${checksum_path}.backup"
        log_info "Backed up existing checksums to ${CHECKSUM_FILE}.backup"
    fi
    
    cd "${EXTENSION_DIR}" || exit 1
    
    local count=0
    {
        echo "# OraDBA Extension Checksums"
        echo "# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "# Version: ${version}"
        echo "# Extension: ${EXTENSION_DIR}"
        echo "#"
        
        while IFS= read -r file; do
            if [[ -f "$file" ]]; then
                checksum_cmd "$file"
                ((count++))
                log_verbose "Added checksum for $file"
            fi
        done < <(get_files_to_checksum)
        
    } > "$checksum_path"
    
    log_success "Updated checksums for $count files"
    log_success "Checksum file: $checksum_path"
    
    # Show what changed if backup exists
    if [[ -f "${checksum_path}.backup" ]]; then
        local added removed
        added=$(comm -13 <(grep -v '^#' "${checksum_path}.backup" | sort) \
                        <(grep -v '^#' "$checksum_path" | sort) | wc -l | tr -d ' ')
        removed=$(comm -23 <(grep -v '^#' "${checksum_path}.backup" | sort) \
                          <(grep -v '^#' "$checksum_path" | sort) | wc -l | tr -d ' ')
        
        log_info "Changes: $added added, $removed removed"
    fi
}

# ------------------------------------------------------------------------------
# Function: verify_checksums
# Purpose.: Verify files against stored checksums
# Returns.: 0 if all files verified, 1 if verification failed or file not found
# Output..: Verification status messages to stderr
# ------------------------------------------------------------------------------
verify_checksums() {
    local checksum_path="${EXTENSION_DIR}/${CHECKSUM_FILE}"
    
    if [[ ! -f "$checksum_path" ]]; then
        log_error "Checksum file not found: $checksum_path"
        log_info "Run without --verify to generate checksums"
        exit 1
    fi
    
    log_info "Verifying checksums in: ${EXTENSION_DIR}"
    
    cd "${EXTENSION_DIR}" || exit 1
    
    local failed=0
    local verified=0
    local missing=0
    
    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        local stored_sum file
        read -r stored_sum file <<< "$line"
        
        if [[ ! -f "$file" ]]; then
            log_error "Missing: $file"
            ((missing++))
            ((failed++))
            continue
        fi
        
        local current_sum
        current_sum=$(checksum_cmd "$file" | awk '{print $1}')
        
        if [[ "$stored_sum" == "$current_sum" ]]; then
            log_verbose "OK: $file"
            ((verified++))
        else
            log_error "MISMATCH: $file"
            ((failed++))
        fi
    done < "$checksum_path"
    
    echo ""
    if [[ $failed -eq 0 ]]; then
        log_success "All $verified files verified successfully"
        return 0
    else
        log_error "Verification failed: $failed errors, $verified OK"
        [[ $missing -gt 0 ]] && log_error "  - $missing missing files"
        [[ $((failed - missing)) -gt 0 ]] && log_error "  - $((failed - missing)) mismatches"
        log_info "Run '${SCRIPT_NAME}' to update checksums"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Function: main
# Purpose.: Main entry point - parse arguments and execute action
# Args....: $@ - Command line arguments
# Returns.: Command exit code
# Output..: Command output and error messages
# ------------------------------------------------------------------------------
main() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verify)
                ACTION="verify"
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Verify we're in an extension directory
    if [[ ! -f "${EXTENSION_DIR}/.extension" ]]; then
        log_error "Not in an OraDBA extension directory"
        log_error "Expected .extension file in: ${EXTENSION_DIR}"
        exit 1
    fi
    
    case "$ACTION" in
        update)
            update_checksums
            ;;
        verify)
            verify_checksums
            ;;
    esac
}

main "$@"
