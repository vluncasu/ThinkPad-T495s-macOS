# Support scope

Support is evidence-driven and limited to the documented Lenovo ThinkPad T495s reference target.

Reference platform:

```text
Lenovo ThinkPad T495s
Machine type: 20QK
AMD Ryzen 7 PRO 3700U
AMD Radeon Vega 10
macOS Ventura 13.7.8 / 22H730
```

Before opening an issue:

1. read `README.md`, `Docs/STATUS.md` and `Docs/KNOWN-ISSUES.md`;
2. reproduce the issue with the public repository configuration without undocumented changes;
3. run the relevant diagnostic collector under `Tools/Diagnostics/`;
4. sanitize SMBIOS values, usernames, hostnames and unrelated personal data;
5. state the exact EFI/repository version, BIOS version and macOS build;
6. distinguish a configured component from an end-to-end function that was actually observed.

Use the GitHub bug-report template for runtime failures. Experimental touchscreen work must be reported as experimental and must not be described as a production feature.

The repository does not claim universal compatibility with other T495s revisions, other Ryzen APUs or other macOS versions.
