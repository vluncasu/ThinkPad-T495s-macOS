#!/usr/bin/env python3
"""Validate the public ThinkPad T495s GitHub release snapshot.

The checks in this script are repository-integrity and documentation-consistency
checks. They do not replace runtime testing on the physical laptop or OpenCore's
matching-version ocvalidate tool.
"""

from __future__ import annotations

import argparse
import hashlib
import os
import plistlib
import re
import sys
from pathlib import Path
from typing import Any, Iterable
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / "EFI/OC/config.plist"
INSTALL_CONFIG = ROOT / "EFI/OC/Config-Profiles/config-install-no-wifi.plist"

EXPECTED_PUBLIC_PLATFORM = {
    "SystemProductName": "MacBookPro16,3",
    "SystemSerialNumber": "C02DEMO00000",
    "MLB": "C02DEMO0000000000",
    "SystemUUID": "00000000-0000-0000-0000-000000000000",
    "ROM": b"\x00\x00\x00\x00\x00\x00",
}

EXPECTED_KEXT_VERSIONS = {
    "AMDRyzenCPUPowerManagement.kext": "0.7.1",
    "AirportItlwm.kext": "2.3.0",
    "AppleALC.kext": "1.9.1",
    "AppleMCEReporterDisabler.kext": "1.2",
    "BlueToolFixup.kext": "2.6.8",
    "BrightnessKeys.kext": "1.0.3",
    "ECEnabler.kext": "1.0.4",
    "EmeraldSDHC.kext": "0.1.2",
    "ForgedInvariant.kext": "1.0.0",
    "IntelBTPatcher.kext": "2.4.0",
    "IntelBluetoothFirmware.kext": "2.4.0",
    "Lilu.kext": "1.7.2",
    "NVMeFix.kext": "1.1.1",
    "NootedRed.kext": "0.9.0",
    "RealtekRTL8111.kext": "2.4.2",
    "RestrictEvents.kext": "1.1.4",
    "SMCBatteryManager.kext": "1.3.3",
    "SMCProcessorAMD.kext": "1.0.1",
    "SMCRadeonSensors.kext": "2.1.0",
    "USBMap.kext": "1.1",
    "VirtualSMC.kext": "1.3.3",
    "VoodooPS2Controller.kext": "2.3.5",
}

REQUIRED_DOCS = [
    "README.md",
    "README.ro.md",
    "RELEASE-NOTES.md",
    "PRIVACY.md",
    "THIRD_PARTY.md",
    "CONTRIBUTING.md",
    "LICENSE.md",
    "SECURITY.md",
    "SUPPORT.md",
    "CHANGELOG.md",
    "RELEASE-CHECKLIST.md",
    "RELEASES/README.md",
    "RELEASES/v17.1.md",
    ".github/release.yml",
    ".github/ISSUE_TEMPLATE/config.yml",
    "Docs/README.md",
    "Docs/STATUS.md",
    "Docs/TEST-MATRIX.md",
    "Docs/HARDWARE.md",
    "Docs/ARCHITECTURE.md",
    "Docs/PREBOOT-COMPATIBILITY.md",
    "Docs/CONFIGURATION.md",
    "Docs/KERNEL-PATCHES.md",
    "Docs/SECURITY.md",
    "Docs/COMPONENTS.md",
    "Docs/GRAPHICS.md",
    "Docs/BRIGHTNESS.md",
    "Docs/INPUT.md",
    "Docs/TOUCHSCREEN.md",
    "Docs/POWER-SLEEP.md",
    "Docs/NETWORKING.md",
    "Docs/STORAGE-USB.md",
    "Docs/AUDIO.md",
    "Docs/BOOT-PICKER.md",
    "Docs/BENCHMARKS.md",
    "Docs/EVIDENCE.md",
    "Docs/METHODOLOGY.md",
    "Docs/DEVELOPMENT-HISTORY.md",
    "Docs/KNOWN-ISSUES.md",
    "Docs/TROUBLESHOOTING.md",
    "Docs/DIAGNOSTICS.md",
    "Docs/BUILD.md",
    "Docs/REFERENCES.md",
    "Docs/GLOSSARY.md",
    "Docs/CHANGELOG.md",
    "Docs/Evidence/GPU-RESET-EXCERPT.txt",
    "Docs/Evidence/SLEEP-EXCERPT.txt",
    "Docs/Evidence/TOUCHSCREEN-EXCERPT.txt",
]

TEXT_EXTENSIONS = {
    ".md", ".txt", ".yml", ".yaml", ".command", ".sh", ".py", ".m", ".c", ".h"
}

# Emoji-oriented ranges. Romanian diacritics and ordinary mathematical/technical
# characters are intentionally not rejected.
EMOJI_RANGES = [
    (0x1F000, 0x1FAFF),
    (0x2600, 0x27BF),
    (0xFE00, 0xFE0F),
    (0x1F1E6, 0x1F1FF),
]

PRIVATE_TEXT_PATTERNS = [
    (re.compile(r"/Users/(?!<name>)[A-Za-z0-9._-]+"), "literal personal macOS home path"),
    (re.compile(r"\bvlad@", re.I), "development user shell prompt"),
    (re.compile(r"vlads-MacBook-Pro", re.I), "development host name"),
    (re.compile(r"\bjameswebb@", re.I), "personal shell prompt"),
]

# Regex is deliberately simple: it validates local inline Markdown destinations,
# which are the form used throughout this repository.
MD_LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")


class Validation:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.warnings: list[str] = []
        self.check_count = 0

    def ok(self, condition: bool, message: str) -> None:
        self.check_count += 1
        if not condition:
            self.errors.append(message)

    def warn(self, condition: bool, message: str) -> None:
        if not condition:
            self.warnings.append(message)

    def finish(self) -> int:
        print(f"Checks executed: {self.check_count}")
        if self.warnings:
            print("Warnings:")
            for item in self.warnings:
                print(f"  - {item}")
        if self.errors:
            print("Validation failed:")
            for item in self.errors:
                print(f"  - {item}")
            return 1
        print("Validation passed.")
        return 0


def load_plist(path: Path) -> Any:
    with path.open("rb") as fh:
        return plistlib.load(fh)


def iter_files() -> Iterable[Path]:
    for path in ROOT.rglob("*"):
        if path.is_file() and ".git" not in path.parts:
            yield path


def plist_version(info: dict[str, Any]) -> str | None:
    value = info.get("CFBundleShortVersionString") or info.get("CFBundleVersion")
    return str(value) if value is not None else None


def deep_diff(a: Any, b: Any, path: str = "") -> list[tuple[str, Any, Any]]:
    differences: list[tuple[str, Any, Any]] = []
    if type(a) is not type(b):
        return [(path, a, b)]
    if isinstance(a, dict):
        keys = sorted(set(a) | set(b))
        for key in keys:
            child = f"{path}/{key}" if path else str(key)
            if key not in a:
                differences.append((child, "<missing>", b[key]))
            elif key not in b:
                differences.append((child, a[key], "<missing>"))
            else:
                differences.extend(deep_diff(a[key], b[key], child))
        return differences
    if isinstance(a, list):
        if len(a) != len(b):
            differences.append((f"{path}/<length>", len(a), len(b)))
        for index, (av, bv) in enumerate(zip(a, b)):
            differences.extend(deep_diff(av, bv, f"{path}/{index}"))
        return differences
    if a != b:
        differences.append((path, a, b))
    return differences


def test_required_files(v: Validation) -> None:
    for rel in REQUIRED_DOCS:
        v.ok((ROOT / rel).is_file(), f"Required documentation file is missing: {rel}")


def test_plists(v: Validation) -> None:
    plists = sorted(ROOT.rglob("*.plist"))
    v.ok(bool(plists), "No plist files were found")
    for path in plists:
        try:
            load_plist(path)
            v.ok(True, f"plist parsed: {path.relative_to(ROOT)}")
        except Exception as exc:
            v.ok(False, f"Invalid plist {path.relative_to(ROOT)}: {exc}")


def test_config_paths(v: Validation, config: dict[str, Any]) -> None:
    acpi_dir = ROOT / "EFI/OC/ACPI"
    driver_dir = ROOT / "EFI/OC/Drivers"
    kext_dir = ROOT / "EFI/OC/Kexts"
    tool_dir = ROOT / "EFI/OC/Tools"

    for entry in config["ACPI"]["Add"]:
        if entry.get("Enabled"):
            rel = entry.get("Path", "")
            v.ok((acpi_dir / rel).is_file(), f"Enabled ACPI file is missing: {rel}")

    for entry in config["UEFI"]["Drivers"]:
        if entry.get("Enabled"):
            rel = entry.get("Path", "")
            v.ok((driver_dir / rel).is_file(), f"Enabled UEFI driver is missing: {rel}")

    for entry in config["Kernel"]["Add"]:
        if entry.get("Enabled"):
            rel = entry.get("BundlePath", "")
            v.ok((kext_dir / rel).exists(), f"Enabled kext bundle path is missing: {rel}")
            plist_rel = entry.get("PlistPath", "")
            if plist_rel:
                v.ok((kext_dir / rel / plist_rel).is_file(), f"Enabled kext Info.plist path is missing: {rel}/{plist_rel}")
            exe_rel = entry.get("ExecutablePath", "")
            if exe_rel:
                v.ok((kext_dir / rel / exe_rel).is_file(), f"Enabled kext executable path is missing: {rel}/{exe_rel}")

    for entry in config["Misc"].get("Tools", []):
        if entry.get("Enabled"):
            rel = entry.get("Path", "")
            v.ok((tool_dir / rel).is_file(), f"Enabled OpenCore tool is missing: {rel}")


def test_public_platform(v: Validation, config: dict[str, Any]) -> None:
    generic = config["PlatformInfo"]["Generic"]
    for key, expected in EXPECTED_PUBLIC_PLATFORM.items():
        v.ok(generic.get(key) == expected, f"Public PlatformInfo {key} is not the expected sanitized placeholder")


def test_profile_invariant(v: Validation, normal: dict[str, Any], installer: dict[str, Any]) -> None:
    diffs = deep_diff(normal, installer)
    v.ok(len(diffs) == 1, f"Installer profile must have exactly one difference from normal config; found {len(diffs)}: {diffs[:8]}")
    if len(diffs) != 1:
        return

    path, normal_value, installer_value = diffs[0]
    parts = path.split("/")
    expected_shape = len(parts) == 4 and parts[0:2] == ["Kernel", "Add"] and parts[3] == "Enabled"
    v.ok(expected_shape, f"Unexpected installer-profile difference path: {path}")
    if not expected_shape:
        return
    try:
        index = int(parts[2])
        normal_entry = normal["Kernel"]["Add"][index]
        installer_entry = installer["Kernel"]["Add"][index]
    except Exception as exc:
        v.ok(False, f"Could not resolve installer-profile difference: {exc}")
        return
    v.ok(normal_entry.get("BundlePath") == "AirportItlwm.kext", "Installer-profile difference is not AirportItlwm.kext")
    v.ok(installer_entry.get("BundlePath") == "AirportItlwm.kext", "Installer-profile entry order/path changed")
    v.ok(normal_value is True and installer_value is False, "Installer profile must change AirportItlwm Enabled from true to false")


def test_release_invariants(v: Validation, config: dict[str, Any]) -> None:
    patches = config["Kernel"]["Patch"]
    v.ok(len(patches) == 22, f"Expected 22 Kernel/Patch entries, found {len(patches)}")
    v.ok(sum(bool(p.get("Enabled")) for p in patches) == 20, "Expected 20 enabled Kernel/Patch entries")

    boot_args = config["NVRAM"]["Add"]["7C436110-AB2A-4BBB-A880-FE41995C9F82"]["boot-args"]
    for token in ["keepsyms=1", "debug=0x100", "npci=0x2000", "alcid=97", "AMDBacklight=1"]:
        v.ok(token in boot_args.split(), f"Required documented boot argument missing: {token}")

    audio = config["UEFI"]["Audio"]
    expected_audio = {
        "AudioSupport": True,
        "AudioDevice": "PciRoot(0x0)/Pci(0x8,0x1)/Pci(0x0,0x6)",
        "AudioCodec": 0,
        "AudioOutMask": 1,
        "PlayChime": "Enabled",
    }
    for key, expected in expected_audio.items():
        v.ok(audio.get(key) == expected, f"Documented UEFI audio invariant changed: {key}")

    comments = {p.get("Comment", ""): p for p in config["ACPI"]["Patch"] if p.get("Enabled")}
    v.ok(any("_OSI to XOSI" in c for c in comments), "Enabled _OSI -> XOSI ACPI patch is missing")
    v.ok(any("NBCF" in c for c in comments), "Enabled NBCF brightness-forwarding ACPI patch is missing")

    expected_acpi = {
        "SSDT-CPUR.aml", "SSDT-EC.aml", "SSDT-HPET.aml", "SSDT-PLUG.aml",
        "SSDT-PNLF.aml", "SSDT-USBX.aml", "SSDT-XOSI.aml",
    }
    enabled_acpi = {e["Path"] for e in config["ACPI"]["Add"] if e.get("Enabled")}
    v.ok(enabled_acpi == expected_acpi, f"Enabled ACPI set differs from documented snapshot: {sorted(enabled_acpi)}")

    enabled_drivers = {e["Path"] for e in config["UEFI"]["Drivers"] if e.get("Enabled")}
    expected_drivers = {"AudioDxe.efi", "HfsPlus.efi", "OpenCanopy.efi", "OpenRuntime.efi", "Ps2KeyboardDxe.efi", "ResetNvramEntry.efi"}
    v.ok(enabled_drivers == expected_drivers, f"Enabled UEFI driver set differs from documented snapshot: {sorted(enabled_drivers)}")

    v.ok(config["Kernel"]["Emulate"].get("DummyPowerManagement") is True, "DummyPowerManagement is expected to be enabled in this AMD snapshot")
    v.ok(config["PlatformInfo"]["Generic"].get("SystemProductName") == "MacBookPro16,3", "SMBIOS product identity must remain MacBookPro16,3 for this release snapshot")


def test_kext_versions(v: Validation) -> None:
    kext_root = ROOT / "EFI/OC/Kexts"
    for name, expected in EXPECTED_KEXT_VERSIONS.items():
        info_path = kext_root / name / "Contents/Info.plist"
        v.ok(info_path.is_file(), f"Expected kext metadata missing: {name}")
        if not info_path.is_file():
            continue
        try:
            info = load_plist(info_path)
        except Exception:
            continue
        actual = plist_version(info)
        v.ok(actual == expected, f"Kext version drift for {name}: expected {expected}, found {actual}")


def test_brightness_source(v: Validation) -> None:
    source = ROOT / "Tools/Brightness/src/T495sBrightnessOverlay.m"
    text = source.read_text(encoding="utf-8")
    v.ok("CGSetDisplayTransferByFormula" not in text, "Rejected continuous gamma API reappeared in v17 brightness source")
    v.ok("CGDisplayRestoreColorSyncSettings" in text, "Documented ColorSync restoration call is missing from v17 brightness source")
    v.ok("IODisplayGetFloatParameter" in text, "v17 overlay no longer reads the native brightness property as documented")

    installer = (ROOT / "Tools/Brightness/Install.command").read_text(encoding="utf-8")
    v.ok("T495sBrightnessBridge" in installer, "Brightness installer no longer removes the obsolete bridge as documented")
    v.ok("--restore-only" in installer, "Brightness installer no longer performs documented restore-only migration")


def test_default_installer_power_isolation(v: Validation) -> None:
    text = (ROOT / "Tools/Install.command").read_text(encoding="utf-8")
    v.ok("pmset" not in text, "Default post-install script must not modify pmset")
    v.ok("Enable-Continuity.command" not in text, "Default post-install script must not install historical lid continuity")
    v.ok("Power/" not in text, "Default post-install script unexpectedly invokes Power helpers")


def test_markdown_links(v: Validation) -> None:
    for path in sorted(ROOT.rglob("*.md")):
        text = path.read_text(encoding="utf-8")
        for match in MD_LINK_RE.finditer(text):
            raw = match.group(1).strip()
            if not raw:
                continue
            # Optional Markdown link title after a whitespace-separated destination.
            if raw.startswith("<") and ">" in raw:
                dest = raw[1:raw.index(">")]
            else:
                dest = raw.split()[0]
            dest = unquote(dest)
            if dest.startswith(("http://", "https://", "mailto:", "tel:", "#")):
                continue
            file_part = dest.split("#", 1)[0].split("?", 1)[0]
            if not file_part:
                continue
            target = (path.parent / file_part).resolve()
            try:
                target.relative_to(ROOT.resolve())
            except ValueError:
                v.ok(False, f"Local Markdown link escapes repository: {path.relative_to(ROOT)} -> {dest}")
                continue
            v.ok(target.exists(), f"Broken local Markdown link: {path.relative_to(ROOT)} -> {dest}")


def is_emoji_char(ch: str) -> bool:
    cp = ord(ch)
    return any(start <= cp <= end for start, end in EMOJI_RANGES)


def test_no_emoji(v: Validation) -> None:
    extensions = {".md", ".txt", ".yml", ".yaml"}
    for path in iter_files():
        if path.suffix.lower() not in extensions:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for line_no, line in enumerate(text.splitlines(), 1):
            chars = "".join(ch for ch in line if is_emoji_char(ch))
            if chars:
                v.ok(False, f"Emoji/dingbat character(s) {chars!r} in {path.relative_to(ROOT)}:{line_no}")


def test_public_text_privacy(v: Validation) -> None:
    for path in iter_files():
        if path == Path(__file__).resolve():
            continue
        if path.suffix.lower() not in TEXT_EXTENSIONS:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        # Documentation may intentionally name a private-path pattern in generic form,
        # but it should not contain a concrete development user/host path.
        for regex, description in PRIVATE_TEXT_PATTERNS:
            for match in regex.finditer(text):
                v.ok(False, f"Possible {description} in {path.relative_to(ROOT)}: {match.group(0)!r}")


def test_status_language(v: Validation) -> None:
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    required_phrases = [
        "## What works",
        "Vega 10",
        "Chrome",
        "Sleep",
        "Wi-Fi",
        "Touchscreen",
        "Metal",
    ]
    for phrase in required_phrases:
        v.ok(phrase in readme, f"README is missing required status coverage: {phrase}")


def parse_manifest_line(line: str) -> tuple[str, str] | None:
    line = line.rstrip("\n")
    if not line.strip():
        return None
    m = re.match(r"^([0-9a-fA-F]{64})\s+\*?(.*)$", line)
    if not m:
        return None
    return m.group(1).lower(), m.group(2)


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def test_manifest(v: Validation) -> None:
    manifest = ROOT / "MANIFEST.sha256"
    v.ok(manifest.is_file(), "MANIFEST.sha256 is missing")
    if not manifest.is_file():
        return
    listed: dict[str, str] = {}
    for line_no, line in enumerate(manifest.read_text(encoding="utf-8").splitlines(), 1):
        parsed = parse_manifest_line(line)
        v.ok(parsed is not None, f"Malformed manifest line {line_no}")
        if parsed is None:
            continue
        digest, rel = parsed
        if rel.startswith("./"):
            rel = rel[2:]
        listed[rel] = digest
        target = ROOT / rel
        v.ok(target.is_file(), f"Manifest entry missing from repository: {rel}")
        if target.is_file():
            v.ok(sha256_file(target) == digest, f"Manifest hash mismatch: {rel}")

    expected_files = {
        p.relative_to(ROOT).as_posix()
        for p in iter_files()
        if p.name != "MANIFEST.sha256" and p.suffix.lower() != ".zip"
    }
    listed_files = set(listed)
    missing = sorted(expected_files - listed_files)
    extra = sorted(listed_files - expected_files)
    v.ok(not missing, f"Files missing from MANIFEST.sha256: {missing[:12]}" + (" ..." if len(missing) > 12 else ""))
    v.ok(not extra, f"Unexpected/stale MANIFEST.sha256 entries: {extra[:12]}" + (" ..." if len(extra) > 12 else ""))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--skip-manifest", action="store_true", help="Skip manifest verification while editing the repository")
    args = parser.parse_args()

    v = Validation()
    v.ok(CONFIG.is_file(), "EFI/OC/config.plist is missing")
    v.ok(INSTALL_CONFIG.is_file(), "Installer no-Wi-Fi profile is missing")
    if not CONFIG.is_file() or not INSTALL_CONFIG.is_file():
        return v.finish()

    normal = load_plist(CONFIG)
    installer = load_plist(INSTALL_CONFIG)

    test_required_files(v)
    test_plists(v)
    test_config_paths(v, normal)
    test_public_platform(v, normal)
    test_public_platform(v, installer)
    test_profile_invariant(v, normal, installer)
    test_release_invariants(v, normal)
    test_kext_versions(v)
    test_brightness_source(v)
    test_default_installer_power_isolation(v)
    test_markdown_links(v)
    test_no_emoji(v)
    test_public_text_privacy(v)
    test_status_language(v)
    if not args.skip_manifest:
        test_manifest(v)

    return v.finish()


if __name__ == "__main__":
    sys.exit(main())
