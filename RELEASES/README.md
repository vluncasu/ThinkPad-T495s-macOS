# GitHub release publication

This directory contains the human-authored release material intended for GitHub Releases.

A GitHub Release itself is a server-side GitHub object and therefore cannot exist as an object inside this repository archive. This repository instead contains everything required to publish it reproducibly:

```text
RELEASES/v17.1.md       complete release body
RELEASE-NOTES.md        engineering release notes
VERSION                 repository/release revision
.github/release.yml     generated-release-note categorization
RELEASE-CHECKLIST.md    publication and verification procedure
MANIFEST.sha256         per-file integrity manifest
```

## Publication convention

```text
Git tag:       v17.1
Release title: ThinkPad T495s macOS v17.1 - documented research snapshot
Release type:  pre-release recommended while GPU stability and native sleep remain unresolved
```

Recommended assets:

```text
ThinkPad-T495s-macOS-v17.1-GitHub-PUBLICATION-COMPLETE.zip
ThinkPad-T495s-macOS-v17.1-GitHub-PUBLICATION-COMPLETE.zip.sha256
```

The release body must not claim stable accelerated graphics, native sleep/resume or production touchscreen support.
