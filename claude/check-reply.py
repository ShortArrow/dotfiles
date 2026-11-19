"""Stop hook: send back a reply that breaks one of two rules the user kept correcting.

1. A reply that says "run the next command" (次のコマンド, 次の 1 行, 次を打って)
   must show it: inline code or a code block. Quoted spans are skipped, so a
   reply that talks about the phrase is not taken as using it.
2. With the user's `language` setting Japanese, a reply of 200 or more
   characters must be at least 5% kana and kanji. Code, inline or fenced, is
   not counted, so a reply that is mostly a code block passes. The length
   counts a run of whitespace as one character; the share ignores it.

Reads the Stop input on stdin and prints a block verdict, or nothing. A stop
already continued by a Stop hook is let through, so a reply is sent back at
most once. The language comes from settings.json in CLAUDE_CONFIG_DIR, or in
~/.claude; an unreadable file means no language, and the second rule is off.
"""
import json
import os
import re
import sys
from pathlib import Path

PROMISE = re.compile(r'次のコマンド|次の\s*[1１一]\s*行|次を(?:打|実行|貼|入力)')
QUOTED = re.compile(r'「[^」]*」|『[^』]*』|"[^"]*"|“[^”]*”')
FENCED = re.compile(r'```.*?(?:```|\Z)', re.DOTALL)
INLINE = re.compile(r'`[^`\n]*`')
JAPANESE_CHAR = re.compile(r'[぀-ヿ㐀-䶿一-鿿豈-﫿ｦ-ﾟ]')
JAPANESE_SETTINGS = {'japanese', '日本語', 'ja', 'ja-jp'}
MIN_LENGTH = 200
MIN_RATIO = 0.05

NO_COMMAND = '返事が「{phrase}」と言っているのにコードが1つもない。直し方：そのコマンドを ` で囲むかコードブロックにして書く。'
NOT_JAPANESE = ('返事が{length}文字あるのに、かな・漢字が{percent:.1f}%しかない（言語設定は日本語）。'
                '直し方：コード以外の文を日本語で書き直す。')


def configured_language(folder=None):
    """The `language` value of settings.json in folder, or None when it cannot be read."""
    folder = folder or os.environ.get('CLAUDE_CONFIG_DIR') or Path.home() / '.claude'
    try:
        value = json.loads(Path(folder, 'settings.json').read_text(encoding='utf-8')).get('language')
    except (OSError, ValueError, AttributeError):
        return None
    return value if isinstance(value, str) else None


def prose(message):
    """The message with fenced and inline code taken out."""
    return INLINE.sub('', FENCED.sub('', message))


def promised_command(message):
    """The phrase that promises a command the message never shows, or None."""
    if '`' in message:
        return None
    found = PROMISE.search(QUOTED.sub('', message))
    return found.group(0) if found else None


def japanese_share(text):
    """(length with each run of whitespace as one character, share of kana and kanji among the rest)."""
    chars = re.sub(r'\s', '', text)
    if not chars:
        return 0, 0.0
    return len(re.sub(r'\s+', ' ', text.strip())), len(JAPANESE_CHAR.findall(chars)) / len(chars)


def verdict(payload, language):
    """The block verdict for a Stop input, or None to let the turn end."""
    if payload.get('stop_hook_active'):
        return None
    message = payload.get('last_assistant_message') or ''
    phrase = promised_command(message)
    if phrase:
        return {'decision': 'block', 'reason': NO_COMMAND.format(phrase=phrase)}
    if (language or '').strip().lower() in JAPANESE_SETTINGS:
        length, share = japanese_share(prose(message))
        if length >= MIN_LENGTH and share < MIN_RATIO:
            return {'decision': 'block', 'reason': NOT_JAPANESE.format(length=length, percent=share * 100)}
    return None


def main():
    try:
        payload = json.loads(sys.stdin.buffer.read().decode('utf-8'))
    except ValueError:
        return
    out = verdict(payload, configured_language()) if isinstance(payload, dict) else None
    if out:
        sys.stdout.buffer.write(json.dumps(out, ensure_ascii=False).encode('utf-8'))


if __name__ == '__main__':
    main()
