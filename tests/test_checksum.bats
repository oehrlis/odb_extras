#!/usr/bin/env bats
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: test_checksum.bats
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.01.21
# Revision...: 0.1.0
# Purpose....: Tests for checksum management script
# Notes......: Verifies checksum creation, update, and verification
# Reference..: https://github.com/oehrlis/odb_extras
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ------------------------------------------------------------------------------

# Test setup
setup() {
    local root
    root="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    export PROJECT_ROOT="$root"
    export CHECKSUM_SCRIPT="${PROJECT_ROOT}/scripts/checksum.sh"
    export USER_CHECKSUM_SCRIPT="${PROJECT_ROOT}/bin/oradba_checksum.sh"
    export CHECKSUM_FILE="${PROJECT_ROOT}/.extension.checksum"
}

teardown() {
    # Clean up any test checksum file backup
    if [[ -f "${CHECKSUM_FILE}.bak" ]]; then
        mv "${CHECKSUM_FILE}.bak" "${CHECKSUM_FILE}"
    fi
}

# ==============================================================================
# Script Existence Tests
# ==============================================================================

@test "Development checksum script exists" {
    [ -f "${CHECKSUM_SCRIPT}" ]
}

@test "Development checksum script is executable" {
    [ -x "${CHECKSUM_SCRIPT}" ]
}

@test "User checksum script exists in bin/" {
    [ -f "${USER_CHECKSUM_SCRIPT}" ]
}

@test "Development checksum script shows help" {
    run "${CHECKSUM_SCRIPT}" help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "User checksum script shows help" {
    run "${USER_CHECKSUM_SCRIPT}" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "Development checksum script lists commands" {
    run "${CHECKSUM_SCRIPT}" help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "create" ]]
    [[ "$output" =~ "update" ]]
    [[ "$output" =~ "verify" ]]
    [[ "$output" =~ "list" ]]
}

@test "User checksum script has verify option" {
    run "${USER_CHECKSUM_SCRIPT}" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "verify" ]]
}

# ==============================================================================
# Functional Tests (non-destructive)
# ==============================================================================

@test "Checksum list works if checksum file exists" {
    skip "Only run if .extension.checksum exists"
    if [ -f "${CHECKSUM_FILE}" ]; then
        run "${CHECKSUM_SCRIPT}" list
        [ "$status" -eq 0 ]
    fi
}

@test "Checksum verify works if checksum file exists" {
    skip "Only run if .extension.checksum exists"
    if [ -f "${CHECKSUM_FILE}" ]; then
        run "${CHECKSUM_SCRIPT}" verify
        [ "$status" -eq 0 ]
    fi
}
