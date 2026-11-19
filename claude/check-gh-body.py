"""PreToolUse guard: a Japanese pull request or issue body goes out only after yomiyasu.

Watches `gh pr|issue create|edit|comment` at a command position, in Bash and
PowerShell alike. A body that is at least 5% kana and kanji is Japanese, and a
Japanese body must come from `--body-file` (or `-F`), because yomiyasu checks
a file it can hash; an inline `--body` or a heredoc piped to `--body-file -`
is refused with that fix. An English body is none of this guard's business.

The file passes when yomiyasu's own `verify` accepts it: the text is piped to
`yomiyasu_check.py verify --final -`, run in the session's directory, and
exit 0 means the state folder holds a run record whose text-sha256 matches.
verify reads the record and writes nothing; calling it rather than hashing
here keeps yomiyasu's normalisation (BOM, line endings, trailing newlines) in
one place. The script is the one installed_plugins.json names for yomiyasu,
the same copy the skill runs, so the record's tool hash matches.

A gate is a check on the agent, not a lock on the user: when yomiyasu, its
interpreter or an answer within the timeout is missing, or verify reports a
usage or internal error (exit 2 or 3), the call goes through. A body file
that cannot be read is refused, since the agent can always name it plainly.
"""
import json
import os
import re
import subprocess
import sys
from pathlib import Path

GH = re.compile(r'(?:^|[;&|(\n])\s*(?:[A-Za-z_]\w*=\S*\s+)*gh\s+(?:pr|issue)\s+(?:create|edit|comment)\b')
BODY_FILE = re.compile(r'(?:--body-file|(?<!\S)-F)(?:=|\s+)(?:"([^"]*)"|\'([^\']*)\'|(\S+))')
INLINE_BODY = re.compile(r'(?:--body(?!-file)|(?<!\S)-b)(?=[=\s])')
LEADING_CD = re.compile(r'^\s*cd\s+(?:"([^"]*)"|\'([^\']*)\'|(\S+))\s*(?:&&|;)')
JAPANESE_CHAR = re.compile(r'[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff\uff66-\uff9f]')
MIN_RATIO = 0.05
VERIFY_TIMEOUT = 8

USE_FILE = '日本語の本文が --body-file を通っていない。直し方：本文をファイルに書き、yomiyasu で推敲して verify を通し、--body-file でそのファイルを渡す。'
UNREADABLE = '--body-file の {path} を読めない。直し方：作業ディレクトリからの相対パスか、Windows の絶対パス（C:/…）で渡す。'
UNVERIFIED = ('日本語の本文 {path} に yomiyasu の verify を通った記録がない。'
              '直し方：yomiyasu で推敲し、yomiyasu_check.py run のあと verify --final {path} が 0 を返してから出す。')


def is_japanese(text):
    """At least MIN_RATIO of the non-space characters are kana or kanji."""
    chars = re.sub(r'\s', '', text)
    return bool(chars) and len(JAPANESE_CHAR.findall(chars)) / len(chars) >= MIN_RATIO


def expand(path):
    """Expand the variable and drive forms a shell would have expanded."""
    path = re.sub(r'\$env:(\w+)', lambda m: os.environ.get(m.group(1), m.group(0)), path, flags=re.IGNORECASE)
    path = re.sub(r'%(\w+)%', lambda m: os.environ.get(m.group(1), m.group(0)), path)
    path = os.path.expanduser(os.path.expandvars(path))
    msys = re.match(r'^/([a-zA-Z])(/.*)?$', path)
    if os.name == 'nt' and msys:
        path = msys.group(1).upper() + ':' + (msys.group(2) or '/')
    return path


def resolve(path, base):
    path = Path(expand(path))
    return path if path.is_absolute() else Path(base, path)


def base_directory(command, cwd):
    cd = LEADING_CD.match(command)
    return resolve(next(g for g in cd.groups() if g is not None), cwd) if cd else Path(cwd)


def yomiyasu_check_script():
    """yomiyasu_check.py of the installed yomiyasu plugin, or None."""
    config = os.environ.get('CLAUDE_CONFIG_DIR') or Path.home() / '.claude'
    try:
        plugins = json.loads(Path(config, 'plugins', 'installed_plugins.json').read_text(encoding='utf-8'))
    except (OSError, ValueError):
        return None
    for name, installs in (plugins.get('plugins') or {}).items():
        if name.split('@')[0] != 'yomiyasu':
            continue
        for install in installs:
            for scripts in ('skills/yomiyasu/scripts', 'scripts'):
                script = Path(install.get('installPath', ''), scripts, 'yomiyasu_check.py')
                if script.is_file():
                    return script
    return None


def yomiyasu_verify(text, cwd):
    """verify's exit code for text, or None when it could not be asked."""
    script = yomiyasu_check_script()
    if script is None:
        return None
    try:
        done = subprocess.run([sys.executable, str(script), 'verify', '--final', '-'], cwd=cwd,
                              input=text.encode('utf-8'), capture_output=True, timeout=VERIFY_TIMEOUT)
    except (OSError, subprocess.SubprocessError):
        return None
    return done.returncode


def deny(reason):
    return {'hookSpecificOutput': {'hookEventName': 'PreToolUse', 'permissionDecision': 'deny',
                                   'permissionDecisionReason': reason}}


def verdict(payload, verify=yomiyasu_verify):
    """The deny verdict for a PreToolUse input, or None to let it through."""
    command = (payload.get('tool_input') or {}).get('command') or ''
    found = GH.search(command)
    if not found:
        return None
    segment = command[found.start():]
    cwd = payload.get('cwd') or os.getcwd()
    body_file = BODY_FILE.search(segment)
    if body_file:
        path = next(g for g in body_file.groups() if g is not None)
        if path == '-':
            return deny(USE_FILE) if is_japanese(segment) else None
        try:
            text = resolve(path, base_directory(command, cwd)).read_text(encoding='utf-8-sig')
        except (OSError, ValueError):
            return deny(UNREADABLE.format(path=path))
        if not is_japanese(text):
            return None
        return deny(UNVERIFIED.format(path=path)) if verify(text, cwd) == 1 else None
    inline = INLINE_BODY.search(segment)
    if inline and is_japanese(segment[inline.end():]):
        return deny(USE_FILE)
    return None


def main():
    try:
        payload = json.loads(sys.stdin.buffer.read().decode('utf-8'))
    except ValueError:
        return
    out = verdict(payload) if isinstance(payload, dict) else None
    if out:
        sys.stdout.buffer.write(json.dumps(out, ensure_ascii=False).encode('utf-8'))


if __name__ == '__main__':
    main()
