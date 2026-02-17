#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# OraDBA - Oracle Database Infrastructure and Security, 5630 Muri, Switzerland
# ------------------------------------------------------------------------------
# Name.......: aliases.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
# Date.......: 2026.02.17
# Revision...: 0.2.0
# Purpose....: Optional odb_extras alias hook
# Notes......: This file is sourced by OraDBA only when BOTH conditions are met:
#              - ORADBA_EXTENSIONS_SOURCE_ETC=true
#              - .extension contains: load_aliases: true
#              Default for odb_extras is load_aliases: false.
# ------------------------------------------------------------------------------

# Example aliases (disabled by default via .extension)
alias extras='cd "${ODB_EXTRAS_BASE:-${ORADBA_LOCAL_BASE}/odb_extras}"'
alias extras-checksum='oradba_checksum.sh --verify'
