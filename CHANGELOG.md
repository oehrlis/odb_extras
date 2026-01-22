# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2026-01-22

### Fixed

- Fixed broken documentation links in `doc/checksums.md`
  - Corrected relative paths to `.checksumignore` (from `.checksumignore` to `../.checksumignore`)
  - Replaced non-existent `development.md` link with proper reference to GitHub Copilot Instructions

## [0.1.0] - 2026-01-21

### Added

- Initial extension structure with OraDBA extension template
- Documentation framework with index and checksum management guides
- Support for user-specific tool wrappers (gnu-tar, oci cli, jq)
- Checksum management system for integrity verification
  - Development script (`scripts/checksum.sh`) for extension developers
  - User script (`bin/oradba_checksum.sh`) for installed extensions
  - Automatic backup of checksum files
  - Support for `.checksumignore` patterns
- Comprehensive test suite with BATS
  - Extension structure tests
  - Checksum script tests
- Makefile with targets for testing, linting, building, and checksum management
- CI/CD ready with GitHub Actions support
- Complete documentation
  - Installation and usage guide
  - Checksum management workflow for users and developers
  - Examples and troubleshooting

### Changed

- Updated `.extension` metadata with correct priority and description

### Fixed

- Markdown linting issues in documentation
- Shell script linting compliance (shellcheck)
- Test framework to handle missing test files gracefully

[Unreleased]: https://github.com/oehrlis/odb_extras/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/oehrlis/odb_extras/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/oehrlis/odb_extras/releases/tag/v0.1.0
