#!/usr/bin/env python3
"""Test an exported initializeKarabiner.data script without touching user config.

Usage: python3 tests/karabiner_activation.py /tmp/karabiner-activation.sh
The script's store PATH is preserved; only its dir/gen assignments are redirected.
"""

import argparse
import json
import os
from pathlib import Path
import re
import stat
import subprocess
import tempfile
import unittest


def snapshot(root, timestamps=False):
    result = {}
    for path in [root, *root.rglob("*")]:
        info = path.lstat()
        data = os.readlink(path) if path.is_symlink() else (
            path.read_bytes() if path.is_file() else None
        )
        value = (stat.S_IFMT(info.st_mode), stat.S_IMODE(info.st_mode), data)
        if timestamps:
            value += (info.st_ino, info.st_mtime_ns, info.st_ctime_ns)
        result[str(path.relative_to(root))] = value
    return result


class KarabinerActivation(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="karabiner activation ")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.directory = self.root / "config home" / "karabiner"
        self.documents = [self.document(f"rules {n}") for n in range(3)]
        self.generated = [self.write_json(self.root / "store inputs" / f"{n}.json", doc, 0o444)
                          for n, doc in enumerate(self.documents)]

    @staticmethod
    def document(name):
        return {"profiles": [{"name": name, "selected": True,
                              "complex_modifications": {"rules": []}}]}

    def write_json(self, path, document, mode=0o600):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(document) + "\n", encoding="utf-8")
        path.chmod(mode)
        return path

    def paths(self):
        return tuple(self.directory / name for name in (
            "karabiner.json", ".nix-generated-karabiner.json", "karabiner.json.hm-bak"))

    def existing(self):
        target, marker, backup = self.paths()
        manual = self.document("manual edits")
        for path, data in zip((target, marker, backup), (manual, self.documents[0], self.document("old backup"))):
            self.write_json(path, data)
        return manual

    def legacy_directory(self):
        manual = self.existing()
        self.write_json(self.directory / "assets" / "custom.json", self.document("asset"), 0o444)
        source = self.directory.parent / "legacy store directory"
        self.directory.rename(source)
        self.directory.symlink_to(source, target_is_directory=True)
        for path in source.rglob("*"):
            if path.is_file():
                path.chmod(0o444)
        return source, manual

    def activate(self, generated, dry=False, success=True, prefix=""):
        environment = {key: value for key, value in os.environ.items()
                       if key not in ("DRY_RUN", "BASH_ENV", "ENV")}
        if dry:
            environment["DRY_RUN"] = ""  # Presence, not a nonempty value, is the contract.
        result = subprocess.run(
            [self.bash, "--noprofile", "--norc", "-c", prefix + "\n" + self.script,
             "karabiner-activation-test", str(self.directory), str(generated)],
            cwd=self.root, env=environment, capture_output=True, text=True, timeout=15)
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)

    def assert_plain(self, path, document):
        self.assertTrue(stat.S_ISREG(path.lstat().st_mode), str(path))
        self.assertEqual(stat.S_IMODE(path.stat().st_mode), 0o600, str(path))
        self.assertEqual(json.loads(path.read_text(encoding="utf-8")), document)

    def test_install_manual_edits_and_rolling_updates(self):
        source_before = snapshot(self.generated[0].parent, timestamps=True)
        self.activate(self.generated[0])
        target, marker, backup = self.paths()
        self.assert_plain(target, self.documents[0])
        self.assert_plain(marker, self.documents[0])
        edited = self.document("edited in the GUI")
        self.write_json(target, edited)
        self.activate(self.generated[0])
        self.assert_plain(target, edited)
        self.assertFalse(backup.exists())
        for index in (1, 2):
            marker.chmod(0o400)
            previous = json.loads(target.read_text(encoding="utf-8"))
            self.activate(self.generated[index])
            self.assert_plain(target, self.documents[index])
            self.assert_plain(marker, self.documents[index])
            self.assert_plain(backup, previous)
            self.assertFalse(os.path.samefile(target, backup))
        self.assertEqual(snapshot(self.generated[0].parent, timestamps=True), source_before)

    def test_dry_run_does_not_write(self):
        for kind in ("new", "ordinary", "JSON links", "directory link"):
            with self.subTest(kind=kind):
                self.directory = self.root / kind / "karabiner"
                if kind == "directory link":
                    self.legacy_directory()
                elif kind != "new":
                    self.existing()
                    if kind == "JSON links":
                        target, _, backup = self.paths()
                        for path, source in ((target, self.generated[0]), (backup, self.generated[2])):
                            path.unlink()
                            path.symlink_to(source)
                before = snapshot(self.root, timestamps=True)
                self.activate(self.generated[1], dry=True)
                self.assertEqual(snapshot(self.root, timestamps=True), before)

    def test_directory_links_migrate_even_when_marker_matches(self):
        for index in (0, 1):
            with self.subTest(changed=bool(index)):
                self.directory = self.root / f"directory case {index}" / "karabiner"
                source, manual = self.legacy_directory()
                before = snapshot(source, timestamps=True)
                self.activate(self.generated[index])
                target, marker, backup = self.paths()
                self.assertFalse(self.directory.is_symlink())
                self.assert_plain(target, self.documents[index] if index else manual)
                self.assert_plain(marker, self.documents[index])
                self.assertEqual((self.directory / "assets/custom.json").read_bytes(), (source / "assets/custom.json").read_bytes())
                if index:
                    self.assert_plain(backup, manual)
                self.assertEqual(snapshot(source, timestamps=True), before)

    def test_json_and_backup_links_become_independent_files(self):
        for index in (0, 1):
            with self.subTest(changed=bool(index)):
                self.directory = self.root / f"file case {index}" / "karabiner"
                self.existing()
                target, marker, backup = self.paths()
                for path, source in ((target, self.generated[0]), (backup, self.generated[2])):
                    path.unlink()
                    path.symlink_to(source)
                before = snapshot(self.generated[0].parent, timestamps=True)
                self.activate(self.generated[index])
                for path, data in ((target, self.documents[index]), (marker, self.documents[index]), (backup, self.documents[0])):
                    self.assert_plain(path, data)
                    self.assertFalse(os.path.samefile(path, self.generated[0]))
                self.assertEqual(snapshot(self.generated[0].parent, timestamps=True), before)

    def test_invalid_generated_json_preserves_existing_state(self):
        for index, contents in enumerate(("{broken JSON", "")):
            with self.subTest(contents=contents):
                self.directory = self.root / f"invalid case {index}" / "karabiner"
                self.existing()
                invalid = self.root / f"invalid source {index}.json"
                invalid.write_text(contents, encoding="utf-8")
                invalid.chmod(0o444)
                before = snapshot(self.root)
                self.activate(invalid, success=False)
                self.assertEqual(snapshot(self.root), before)

    def test_broken_links_and_wrong_file_types_preserve_state(self):
        for kind in ("directory link", "JSON link", "source link", "target directory", "marker directory", "backup directory"):
            with self.subTest(kind=kind):
                self.directory = self.root / kind / "karabiner"
                self.existing()
                target, marker, backup = self.paths()
                generated = self.generated[1]
                if kind == "directory link":
                    self.directory.rename(self.directory.parent / "original directory")
                    self.directory.symlink_to(self.root / "missing directory", target_is_directory=True)
                elif kind == "source link":
                    generated = self.root / "broken generation.json"
                    generated.symlink_to(self.root / "missing generation.json")
                else:
                    path = {"JSON link": target, "target directory": target, "marker directory": marker, "backup directory": backup}[kind]
                    path.unlink()
                    if kind == "JSON link":
                        path.symlink_to(self.root / "missing config.json")
                    else:
                        self.write_json(path / "keep.json", self.document("must survive"))
                before = snapshot(self.root)
                self.activate(generated, success=False)
                self.assertEqual(snapshot(self.root), before)

    def test_failed_directory_publish_restores_original_link(self):
        source, _ = self.legacy_directory()
        before, source_before = snapshot(self.root), snapshot(source, timestamps=True)
        reject_publish = '''mv() {
          if [[ ${3-} == "$dir".activation.*/config && ${4-} == "$dir" ]]; then return 73; fi
          command mv "$@"
        }'''
        self.activate(self.generated[1], success=False, prefix=reject_publish)
        self.assertEqual(snapshot(self.root), before)
        self.assertEqual(snapshot(source, timestamps=True), source_before)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("activation_script", type=Path)
    parser.add_argument("--bash", default="bash", help="Bash with [[ -v ]] support (4.2 or newer)")
    arguments = parser.parse_args()
    script = arguments.activation_script.read_text(encoding="utf-8")
    for name, position in (("dir", 1), ("gen", 2)):
        script, count = re.subn(rf"(?m)^([ \t]*){name}=.*$", lambda match: f'{match[1]}{name}="${position}"', script)
        if count != 1:
            parser.error(f"expected exactly one standalone {name}= assignment, found {count}")
    KarabinerActivation.script, KarabinerActivation.bash = script, arguments.bash
    unittest.main(argv=[__file__], verbosity=2)
