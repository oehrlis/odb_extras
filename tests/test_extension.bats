#!/usr/bin/env bats
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: test_extension.bats
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Editor.....: Stefan Oehrli
# Date.......: 2025.01.21
# Revision...: 0.1.0
# Purpose....: Basic tests for OraDBA Extras extension
# Notes......: These tests verify the extension structure and metadata
# Reference..: https://github.com/oehrlis/odb_extras
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ------------------------------------------------------------------------------

# Test setup
setup() {
    # Get the project root directory
    local root
    root="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    export PROJECT_ROOT="$root"
}

# ==============================================================================
# Extension Metadata Tests
# ==============================================================================

@test "Extension metadata file exists" {
    [ -f "${PROJECT_ROOT}/.extension" ]
}

@test "VERSION file exists and contains valid version" {
    [ -f "${PROJECT_ROOT}/VERSION" ]
    version=$(cat "${PROJECT_ROOT}/VERSION")
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "README.md exists" {
    [ -f "${PROJECT_ROOT}/README.md" ]
}

@test "LICENSE file exists" {
    [ -f "${PROJECT_ROOT}/LICENSE" ]
}

@test "CHANGELOG.md exists" {
    [ -f "${PROJECT_ROOT}/CHANGELOG.md" ]
}

# ==============================================================================
# Directory Structure Tests
# ==============================================================================

@test "bin directory exists" {
    [ -d "${PROJECT_ROOT}/bin" ]
}

@test "etc directory exists" {
    [ -d "${PROJECT_ROOT}/etc" ]
}

@test "doc directory exists" {
    [ -d "${PROJECT_ROOT}/doc" ]
}

@test "scripts directory exists" {
    [ -d "${PROJECT_ROOT}/scripts" ]
}

# ==============================================================================
# Script Tests
# ==============================================================================

@test "build.sh exists and is executable" {
    [ -x "${PROJECT_ROOT}/scripts/build.sh" ]
}

@test "rename-extension.sh exists and is executable" {
    [ -x "${PROJECT_ROOT}/scripts/rename-extension.sh" ]
}
