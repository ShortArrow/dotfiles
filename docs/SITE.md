# The site

`dotfiles.shortarrow.jp` is a Hugo build of this repository, published by
Cloudflare Pages from its Git integration. Nothing in `.github/` deploys it;
the workflow only checks that it builds.

## Layout

```
config/_default/       Hugo configuration, split by concern
  config.toml            baseURL, languages served, taxonomies off
  languages.*.toml       per-language title, description, author
  menus.*.toml           header and footer entries, per language
  module.toml            content mounts (see below)
  markup.toml            Goldmark and Chroma
  params.toml            the few params the templates read
content/               pages written for the site, <name>.<lang>.md
layouts/               the templates; there is no theme
  _default/              baseof, list, single, and the heading render hook
  partials/              head, header, footer, breadcrumbs, card grid
  shortcodes/            button, alert
  index.html             home
  404.html
assets/css/
  main.css               design tokens and every rule that is written by hand
  syntax.css             generated — see scripts/gen-syntax-css.sh
i18n/{en,ja}.toml      strings that appear in templates rather than content
```

## Templates instead of a theme

The site used the congo theme until the day its version matrix stopped having
a solution: congo v2.13 builds on Hugo 0.147 and fails on 0.164, v2.14 is the
reverse, and Cloudflare's build image ships 0.147. Overriding a theme's
prebuilt Tailwind CSS to get a card grid was also more work than writing the
grid.

What replaced it is about 400 lines of template and CSS in this repository,
with no build step and no dependency. `hugo` alone builds the site.

## Two kinds of page source

Pages written for the site live under `content/`, one file per language:
`notes/path-budget.en.md` and `notes/path-budget.ja.md` are the same page.

Tool documentation does not. Each tool's readme lives beside the configuration
it documents, and `module.toml` mounts it into `content/docs/`. There is one
copy, and it is the one a checkout carries.

Mounts have two rules that are easy to get wrong and produce no build error:

- **Declaring any mount replaces the default one.** So `content/` itself is
  mounted explicitly; remove that entry and every written page disappears.
- **A mounted page's language is the suffix of its target**, as for a
  written page: `content/docs/bash.ja.md`. A mount's `lang` is not used,
  because no spelling of it builds on both 0.147 and 0.168 — see Versions.

Symlinks under `content/` do not work. Hugo skips them on Linux, and a Windows
checkout writes them as text files whose contents are the target path — which
renders as a one-word page. Neither failure appears in the build output.

The tool readmes are English. They are mounted into both languages so that
`/ja/docs/` is navigable; the Japanese section index says the pages themselves
are in English.

## Appearance

`assets/css/main.css` declares both appearances as custom properties. The
default follows `prefers-color-scheme`; the toggle in the header writes
`appearance` to `localStorage` and stamps `data-theme` on `<html>`, which wins
over the media query in both directions. A small script in `<head>` applies
the stored value before first paint.

`syntax.css` is generated, because Chroma emits one theme per run and the page
needs both. `scripts/gen-syntax-css.sh` builds a light one and a dark one and
scopes the dark rules to the same two selectors.

## Versions

| Where | Version | Why |
|---|---|---|
| Cloudflare Pages | 0.147 | Fixed by their build image. Hugo has no version file they read, and Workers Builds ignores build settings in the Wrangler config. |
| `mise.toml` | 0.147.7 | Matches the deploy, so a local build proves something about it. |
| CI | 0.147.7 and latest | The pinned build is the gate. The latest build is warning of what a Cloudflare image upgrade will bring. |

The latest build passes with deprecation warnings, and they stay until
Cloudflare moves: `languageName` / `languageCode` are replaced by `label` /
`locale` in 0.158, and neither replacement exists in 0.147. Silencing them
would also silence the warning this build exists to give.

`mounts.lang` went the same way and was removed in 0.168, which turned the
warning into a failed build. Languages are told by file name instead, which
both versions read, so the configuration has no `lang` left to remove.

## Checks

- `scripts/check-content-parity.sh` — a page added or edited in one language
  only still builds and still renders, and says something different depending
  on which language the reader picked. Edits that genuinely belong to one
  language are declared in `scripts/parity-exceptions.txt`.
  `scripts/check-content-parity.test.sh` exercises it in throwaway
  repositories.
- The markdown link check runs over `content/`.
