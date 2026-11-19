"""Exercise check-reply.py against the Stop inputs it sees.

Run: python claude/check-reply.test.py
"""
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('check_reply', HERE / 'check-reply.py')
hook = importlib.util.module_from_spec(spec)
spec.loader.exec_module(hook)


def stop(message, active=False):
    return {'hook_event_name': 'Stop', 'stop_hook_active': active, 'last_assistant_message': message}


class Base(unittest.TestCase):
    language = 'Japanese'

    def verdict(self, payload):
        return hook.verdict(payload, self.language)

    def assertBlocked(self, out, *words):
        self.assertIsNotNone(out)
        self.assertEqual(out['decision'], 'block')
        self.assertNotIn('\n', out['reason'])
        for word in words:
            self.assertIn(word, out['reason'])


class PromisedCommand(Base):
    def test_promise_without_code_is_blocked(self):
        for phrase in ('次のコマンドを実行してください。', '次の 1 行を打ってください。', '次の1行を貼ってください。',
                       '次を打ってください。', '次を実行してください。'):
            self.assertBlocked(self.verdict(stop('ビルドが終わりました。' + phrase)), 'コマンド')

    def test_promise_with_inline_code_passes(self):
        self.assertIsNone(self.verdict(stop('次のコマンドを打ってください：`/rename public-home-dotfiles`')))

    def test_promise_with_code_block_passes(self):
        self.assertIsNone(self.verdict(stop('次を実行してください。\n\n```\ngit status\n```\n')))

    def test_quoted_phrase_is_not_a_promise(self):
        self.assertIsNone(self.verdict(stop('返事に「次のコマンド」とあってコードがないと止めるフックを足しました。')))

    def test_reply_without_the_phrase_passes(self):
        self.assertIsNone(self.verdict(stop('コミットしました。push は待ちます。')))


class ReplyLanguage(Base):
    english = ('The build finished and the tests passed. I committed the change locally and did not push it, '
               'because the pre-push hook still refuses the three names that the user has not decided on yet. '
               'The next step waits for that decision.')

    def test_long_english_reply_is_blocked(self):
        self.assertGreaterEqual(len(self.english), 200)
        self.assertBlocked(self.verdict(stop(self.english)), '日本語')

    def test_short_english_reply_passes(self):
        self.assertIsNone(self.verdict(stop('Done. Committed as abc1234.')))

    def test_japanese_reply_passes(self):
        self.assertIsNone(self.verdict(stop('ビルドとテストが通りました。' + self.english)))

    def test_code_block_is_not_counted(self):
        code = '```\n' + 'x = 1\n' * 100 + '```\n'
        self.assertIsNone(self.verdict(stop('設定を直しました。\n\n' + code)))
        self.assertIsNone(self.verdict(stop('設定を直しました。`' + 'a' * 300 + '`')))

    def test_boundaries(self):
        # 200 non-space characters, 10 of them Japanese: exactly 5%, passes.
        self.assertIsNone(self.verdict(stop('あ' * 10 + 'a' * 190)))
        # 9 of 200 is below 5%.
        self.assertBlocked(self.verdict(stop('あ' * 9 + 'a' * 191)), '日本語')
        # 199 characters is short enough to pass whatever its language.
        self.assertIsNone(self.verdict(stop('a' * 199)))

    def test_other_language_setting_passes(self):
        for language in ('English', None, ''):
            self.assertIsNone(hook.verdict(stop(self.english), language))

    def test_language_spellings(self):
        for language in ('japanese', '日本語', 'ja'):
            self.assertIsNotNone(hook.verdict(stop(self.english), language))


class Loop(Base):
    def test_a_continued_stop_passes(self):
        self.assertIsNone(self.verdict(stop('次のコマンドを打ってください。', active=True)))
        self.assertIsNone(self.verdict(stop(ReplyLanguage.english, active=True)))


class Settings(unittest.TestCase):
    def test_language_is_read_from_settings(self):
        folder = tempfile.mkdtemp()
        Path(folder, 'settings.json').write_text(json.dumps({'language': 'Japanese'}), encoding='utf-8')
        self.assertEqual(hook.configured_language(folder), 'Japanese')

    def test_missing_or_broken_settings_give_no_language(self):
        folder = tempfile.mkdtemp()
        self.assertIsNone(hook.configured_language(folder))
        Path(folder, 'settings.json').write_text('{', encoding='utf-8')
        self.assertIsNone(hook.configured_language(folder))


if __name__ == '__main__':
    unittest.main(verbosity=1)
