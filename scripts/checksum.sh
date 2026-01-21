#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: checksum.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.01.21
# Revision...: 1.0.0
# Purpose....: Manage extension checksums - verify, update, or create
# Notes......: This script helps maintain integrity of extension files
# Reference..: https://github.com/oehrlis/odb_extras
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ------------------------------------------------------------------------------

set -euo pipefail

# Script configuration
SCRIPT_NAME="$(basename "${0}")"
SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly SCRIPT_NAME
readonly SCRIPT_DIR
readonly PROJECT_ROOT
readonly CHECKSUM_FILE=".extension.checksum"
readonly CHECKSUMIGNORE_FILE=".checksumignore"

# Color output
readonly COLOR_RESET='\033[0m'
readonly COLOR_GREEN='\033[32m'
readonly COLOR_YELLOW='\033[33m'
readonly COLOR_RED='\033[31m'
readonly COLOR_BLUE='\033[34m'

# Command configuration
COMMAND=""
VERBOSE=false

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Function: show_usage
# Purpose.: Display usage information and available commands
# Returns.: 0
# Output..: Usage information to stdout
# ------------------------------------------------------------------------------
show_usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} <command> [OPTIONS]

Manage OraDBA extension checksums for integrity verification.

Commands:
  create              Create new checksum file
  update              Update existing checksum file
  verify              Verify files against checksum file
  check               Alias for verify
  list                List files included in checksum
  help                Show this help message

Options:
  -v, --verbose       Show detailed output
  -h, --help          Show this help message

Examples:
  ${SCRIPT_NAME} create         # Create new checksum file
  ${SCRIPT_NAME} update         # Update existing checksums
  ${SCRIPT_NAME} verify         # Verify file integrity
  ${SCRIPT_NAME} list           # List checksummed files

Description:
  This script manages the .extension.checksum file that ensures integrity
  of extension files. It respects .checksumignore patterns when creating
  or updating checksums.

  The checksum file is created during build but can be managed manually:
  - Create: Generate initial checksum file
  - Update: Regenerate checksums for all tracked files
  - Verify: Check if files match their stored checksums
  - List: Show which files are tracked

EOF
}

# ------------------------------------------------------------------------------
# Function: log_info
# Purpose.: Log informational messages to stderr
# Args....: $@ - Message to log
# Returns.: 0
# Output..: Blue INFO message to stderr
# ------------------------------------------------------------------------------
log_info() {
    echo -e "${COLOR_BLUE}INFO:${COLOR_RESET} $*" >&2
}

# ------------------------------------------------------------------------------
# Function: log_success
# Purpose.: Log success messages to stderr with green checkmark
# Args....: $@ - Message to log
# Returns.: 0
# Output..: Green checkmark message to stderr
# ------------------------------------------------------------------------------
log_success() {
    echo -e "${COLOR_GREEN}✓${COLOR_RESET} $*" >&2
}

# ------------------------------------------------------------------------------
# Function: log_warning
# Purpose.: Log warning messages to stderr
# Args....: $@ - Message to log
# Returns.: 0
# Output..: Yellow WARNING message to stderr
# ------------------------------------------------------------------------------
log_warning() {
    echo -e "${COLOR_YELLOW}WARNING:${COLOR_RESET} $*" >&2
}

# ------------------------------------------------------------------------------
# Function: log_error
# Purpose.: Log error messages to stderr
# Args....: $@ - Message to log
# Returns.: 0
# Output..: Red ERROR message to stderr
# ------------------------------------------------------------------------------
log_error() {
    echo -e "${COLOR_RED}ERROR:${COLOR_RESET} $*" >&2
}

# ------------------------------------------------------------------------------
# Function: log_verbose
# Purpose.: Log verbose messages to stderr (only if VERBOSE=true)
# Args....: $@ - Message to log
# Returns.: 0
# Output..: Blue VERBOSE message to stderr (conditional)
# ------------------------------------------------------------------------------
log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${COLOR_BLUE}VERBOSE:${COLOR_RESET} $*" >&2
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
    local ignore_file="${PROJECT_ROOT}/${CHECKSUMIGNORE_FILE}"
    
    # Always exclude these files
    [[ "$file" == "$CHECKSUM_FILE" ]] && return 0
    [[ "$file" == ".extension" ]] && return 0
    [[ "$file" == "$CHECKSUMIGNORE_FILE" ]] && return 0
    [[ "$file" == ".git"* ]] && return 0
    
    # Check .checksumignore patterns
    if [[ -f "$ignore_file" ]]; then
        while IFS= read -r pattern; do
            # Skip comments and empty lines
            [[ "$pattern" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${pattern// }" ]] && continue
            
            # Match pattern
            if [[ "$file" == "$pattern" ]]; then
                log_verbose "Excluding $file (matches pattern: $pattern)"
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
    
    cd "${PROJECT_ROOT}" || exit 1
    
    # Define directories and files typically included in extensions
    local -a include_patterns=(
        "VERSION"
        "README.md"
        "CHANGELOG.md"
        "LICENSE"
        "bin"
        "sql"
        "rcv"
        "etc"
        "lib"
        "doc"
    )
    
    for pattern in "${include_patterns[@]}"; do
        if [[ -d "$pattern" ]]; then
            while IFS= read -r -d '' file; do
                if ! should_exclude "$file"; then
                    files+=("$file")
                fi
            done < <(find "$pattern" -type f -print0 2>/dev/null)
        elif [[ -f "$pattern" ]]; then
            if ! should_exclude "$pattern"; then
                files+=("$pattern")
            fi
        fi
    done
    
    printf '%s\n' "${files[@]}" | sort -u
}

# ------------------------------------------------------------------------------
# Command Functions
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Function: cmd_create
# Purpose.: Create initial checksum file
# Returns.: 1 if checksum file already exists, 0 on success
# Output..: Status messages to stderr
# ------------------------------------------------------------------------------
cmd_create() {
    local checksum_path="${PROJECT_ROOT}/${CHECKSUM_FILE}"
    
    if [[ -f "$checksum_path" ]]; then
        log_warning "Checksum file already exists: $checksum_path"
        log_info "Use 'update' command to regenerate checksums"
        exit 1
    fi
    
    log_info "Creating checksum file..."
    _generate_checksum_file
    log_success "Checksum file created: $CHECKSUM_FILE"
}

# ------------------------------------------------------------------------------
# Function: cmd_update
# Purpose.: Update existing checksum file
# Returns.: 1 if checksum file doesn't exist, 0 on success
# Output..: Status messages to stderr
# ------------------------------------------------------------------------------
cmd_update() {
    local checksum_path="${PROJECT_ROOT}/${CHECKSUM_FILE}"
    
    if [[ ! -f "$checksum_path" ]]; then
        log_warning "Checksum file does not exist: $checksum_path"
        log_info "Use 'create' command to generate initial checksums"
        exit 1
    fi
    
    log_info "Updating checksum file..."
    rm -f "$checksum_path"
    _generate_checksum_file
    log_success "Checksum file updated: $CHECKSUM_FILE"
}

# ------------------------------------------------------------------------------
# Function: _generate_checksum_file
# Purpose.: Internal function to generate checksum file content
# Returns.: 0
# Output..: Status messages to stderr
# Notes...: Creates checksum file with header and file checksums
# ------------------------------------------------------------------------------
_generate_checksum_file() {
    local checksum_path="${PROJECT_ROOT}/${CHECKSUM_FILE}"
    local version
    version=$(cat "${PROJECT_ROOT}/VERSION" 2>/dev/null || echo "unknown")
    
    cd "${PROJECT_ROOT}" || exit 1
    
    {
        echo "# OraDBA Extension Checksums"
        echo "# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "# Version: ${version}"
        echo "#"
        
        local count=0
        while IFS= read -r file; do
            if [[ -f "$file" ]]; then
                checksum_cmd "$file"
                ((count++))
                log_verbose "Added checksum for $file"
            fi
        done < <(get_files_to_checksum)
        
    } > "$checksum_path"
    
    log_info "Generated checksums for $count files"
}

# ------------------------------------------------------------------------------
# Function: cmd_verify
# Purpose.: Verify files against stored checksums
# Returns.: 0 if all files verified, 1 if verification failed or file not found
# Output..: Verification status messages to stderr
# ------------------------------------------------------------------------------
cmd_verify() {
    local checksum_path="${PROJECT_ROOT}/${CHECKSUM_FILE}"
    
    if [[ ! -f "$checksum_path" ]]; then
        log_error "Checksum file not found: $checksum_path"
        log_info "Run '${SCRIPT_NAME} create' to generate checksums"
        exit 1
    fi
    
    log_info "Verifying file integrity..."
    
    cd "${PROJECT_ROOT}" || exit 1
    
    local failed=0
    local verified=0
    local missing=0
    
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # Parse checksum and filename
        local stored_sum file
        read -r stored_sum file <<< "$line"
        
        if [[ ! -f "$file" ]]; then
            log_error "Missing file: $file"
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
            log_error "FAILED: $file (checksum mismatch)"
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
        [[ $((failed - missing)) -gt 0 ]] && log_error "  - $((failed - missing)) checksum mismatches"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Function: cmd_list
# Purpose.: List all files tracked in checksum file
# Returns.: 1 if checksum file not found, 0 on success
# Output..: List of tracked files to stdout, summary to stderr
# ------------------------------------------------------------------------------
cmd_list() {
    local checksum_path="${PROJECT_ROOT}/${CHECKSUM_FILE}"
    
    if [[ ! -f "$checksum_path" ]]; then
        log_error "Checksum file not found: $checksum_path"
        exit 1
    fi
    
    log_info "Files tracked in checksum:"
    echo ""
    
    grep -v '^#' "$checksum_path" | grep -v '^[[:space:]]*$' | awk '{print "  " $2}'
    
    local count
    count=$(grep -cv '^#' "$checksum_path" || echo "0")
    echo ""
    log_info "Total: $count files"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Function: main
# Purpose.: Main entry point - parse arguments and execute command
# Args....: $@ - Command line arguments
# Returns.: Command exit code
# Output..: Command output and error messages
# ------------------------------------------------------------------------------
main() {
    # Parse arguments
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 0
    fi
    
    COMMAND="$1"
    shift
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verbose)
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
    
    # Execute command
    case "$COMMAND" in
        create)
            cmd_create
            ;;
        update)
            cmd_update
            ;;
        verify|check)
            cmd_verify
            ;;
        list)
            cmd_list
            ;;
        help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown command: $COMMAND"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
