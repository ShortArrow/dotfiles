"""Exercise check-gh-body.py against the commands the PreToolUse hook sees.

Run: python claude/check-gh-body.test.py

The yomiyasu verify call is replaced by a stub that reports whether the text
it was handed is in a set of verified texts, so no plugin is needed here.
"""
import importlib.util
import os
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('check_gh_body', HERE / 'check-gh-body.py')
hook = importlib.util.module_from_spec(spec)
spec.loader.exec_module(hook)

JA = '## 変更\n\nZebar を起動するスクリプトを追加しました。標準エラーをファイルに残します。\n'
EN = '## Change\n\nAdds a script that starts Zebar and keeps its stderr in a file.\n'


MISSING = object()


class Stub:
    """verify stand-in: 0 for a verified text, 1 otherwise, or a fixed code."""

    def __init__(self, verified=(), code=None):
        self.verified = set(verified)
        self.code = code
        self.calls = []

    def __call__(self, text, cwd):
        self.calls.append((text, cwd))
        if self.code is MISSING:
            return None
        if self.code is not None:
            return self.code
        return 0 if text in self.verified else 1


class GhBody(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()
        self.ja = Path(self.dir, 'body.md')
        self.ja.write_text(JA, encoding='utf-8')
        self.en = Path(self.dir, 'body-en.md')
        self.en.write_text(EN, encoding='utf-8')

    def verdict(self, command, verify=None):
        payload = {'cwd': self.dir, 'tool_input': {'command': command}}
        return hook.verdict(payload, verify or Stub())

    def assertDenied(self, out, *words):
        self.assertIsNotNone(out)
        reason = out['hookSpecificOutput']['permissionDecisionReason']
        self.assertEqual(out['hookSpecificOutput']['permissionDecision'], 'deny')
        self.assertNotIn('\n', reason)
        for word in words:
            self.assertIn(word, reason)

    # -- commands that are none of this hook's business

    def test_other_commands_pass(self):
        self.assertIsNone(self.verdict('git status'))
        self.assertIsNone(self.verdict('gh pr view 12'))
        self.assertIsNone(self.verdict('gh pr merge 12 --squash'))

    def test_gh_only_at_a_command_position(self):
        self.assertIsNone(self.verdict(f"grep -n 'gh pr create --body \"{JA}\"' notes.md"))
        self.assertIsNone(self.verdict(f'git commit -m "docs: say gh pr create --body {JA}"'))

    # -- an inline body

    def test_inline_japanese_body_needs_a_file(self):
        for flag in ('--body', '-b'):
            self.assertDenied(self.verdict(f'gh pr create --title t {flag} "{JA}"'), '--body-file')
        self.assertDenied(self.verdict(f'gh issue comment 3 --body="{JA}"'), '--body-file')

    def test_inline_japanese_heredoc_needs_a_file(self):
        command = f"gh pr comment 5 --body \"$(cat <<'EOF'\n{JA}EOF\n)\""
        self.assertDenied(self.verdict(command), '--body-file')

    def test_powershell_here_string_needs_a_file(self):
        command = f"gh issue create --title t --body @'\n{JA}'@"
        self.assertDenied(self.verdict(command), '--body-file')

    def test_inline_english_body_passes(self):
        self.assertIsNone(self.verdict(f'gh pr create --title t --body "{EN}"'))

    def test_japanese_title_alone_passes(self):
        self.assertIsNone(self.verdict('gh pr edit 4 --title "起動を直す"'))

    def test_every_subcommand_is_checked(self):
        for noun in ('pr', 'issue'):
            for verb in ('create', 'edit', 'comment'):
                self.assertDenied(self.verdict(f'gh {noun} {verb} 1 --body "{JA}"'), '--body-file')

    def test_after_another_command(self):
        self.assertDenied(self.verdict(f'cd {self.dir} && gh pr create --body "{JA}"'), '--body-file')

    # -- a body file

    def test_verified_japanese_file_passes(self):
        stub = Stub(verified=[JA])
        self.assertIsNone(self.verdict(f'gh pr create --title t --body-file {self.ja}', stub))
        self.assertEqual(stub.calls, [(JA, self.dir)])

    def test_unverified_japanese_file_is_denied(self):
        self.assertDenied(self.verdict(f'gh pr create --body-file {self.ja}'), 'yomiyasu', 'verify')

    def test_english_file_is_not_verified(self):
        stub = Stub()
        self.assertIsNone(self.verdict(f'gh pr create --body-file {self.en}', stub))
        self.assertEqual(stub.calls, [])

    def test_file_flag_spellings(self):
        stub = Stub(verified=[JA])
        for form in (f'-F {self.ja}', f'--body-file={self.ja}', f'--body-file "{self.ja}"',
                     f"--body-file '{self.ja}'"):
            self.assertIsNone(self.verdict(f'gh issue comment 2 {form}', stub), form)

    def test_relative_file_resolves_against_cwd(self):
        stub = Stub(verified=[JA])
        self.assertIsNone(self.verdict('gh pr create --body-file body.md', stub))

    def test_relative_file_resolves_against_a_leading_cd(self):
        sub = Path(self.dir, 'sub')
        sub.mkdir()
        Path(sub, 'b.md').write_text(JA, encoding='utf-8')
        stub = Stub(verified=[JA])
        self.assertIsNone(self.verdict(f'cd {sub} && gh pr create --body-file b.md', stub))

    def test_msys_drive_path_resolves(self):
        if os.name != 'nt':
            self.skipTest('MSYS paths exist only on Windows')
        drive, rest = os.path.splitdrive(str(self.ja))
        msys = '/' + drive[0].lower() + rest.replace('\\', '/')
        stub = Stub(verified=[JA])
        self.assertIsNone(self.verdict(f'gh pr create --body-file {msys}', stub))

    def test_env_variable_path_resolves(self):
        os.environ['CHECK_GH_BODY_TEST_DIR'] = self.dir
        stub = Stub(verified=[JA])
        for form in ('$CHECK_GH_BODY_TEST_DIR/body.md', '"$CHECK_GH_BODY_TEST_DIR/body.md"',
                     '$env:CHECK_GH_BODY_TEST_DIR\\body.md'):
            self.assertIsNone(self.verdict(f'gh pr create --body-file {form}', stub), form)

    def test_unreadable_file_is_denied(self):
        self.assertDenied(self.verdict('gh pr create --body-file missing.md'), 'missing.md')

    def test_stdin_body_file_with_japanese_in_the_command_is_denied(self):
        command = f"gh pr comment 5 --body-file - <<'EOF'\n{JA}EOF"
        self.assertDenied(self.verdict(command), '--body-file')

    def test_stdin_body_file_without_japanese_passes(self):
        self.assertIsNone(self.verdict(f"gh pr comment 5 --body-file - <<'EOF'\n{EN}EOF"))

    # -- when yomiyasu cannot answer

    def test_verify_unavailable_lets_through(self):
        # verify returns None when yomiyasu or its interpreter is not there.
        self.assertIsNone(self.verdict(f'gh pr create --body-file {self.ja}', Stub(code=MISSING)))

    def test_verify_usage_or_internal_error_lets_through(self):
        for code in (2, 3):
            self.assertIsNone(self.verdict(f'gh pr create --body-file {self.ja}', Stub(code=code)))


class Ratio(unittest.TestCase):
    def test_boundary(self):
        # 5 Japanese characters in 100 non-space characters is exactly 5%.
        at = 'あ' * 5 + 'a' * 95
        below = 'あ' * 4 + 'a' * 96
        self.assertTrue(hook.is_japanese(at))
        self.assertFalse(hook.is_japanese(below))

    def test_whitespace_is_not_counted(self):
        self.assertTrue(hook.is_japanese('あ' * 5 + ' ' * 500 + 'a' * 95))

    def test_empty(self):
        self.assertFalse(hook.is_japanese(''))


if __name__ == '__main__':
    unittest.main(verbosity=1)
