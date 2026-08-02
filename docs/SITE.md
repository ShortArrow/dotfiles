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
content/{en,ja}/       pages written for the site
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

Pages written for the site live under `content/en/` and `content/ja/`.

Tool documentation does not. Each tool's readme lives beside the configuration
it documents, and `module.toml` mounts it into `content/docs/`. There is one
copy, and it is the one a checkout carries.

Mounts have two rules that are easy to get wrong and produce no build error:

- **Declaring any mount replaces the default one**, and mounts override each
  language's `contentDir`. So `content/en` and `content/ja` are mounted
  explicitly; remove those two entries and every page disappears.
- **Every mount needs `lang`**, or its pages resolve in no language.

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
Cloudflare moves: `mounts.lang` is replaced by `sites.matrix` in 0.153, and
`languageName` / `languageCode` by `label` / `locale` in 0.158. None of the
replacements exists in 0.147, so there is no spelling that satisfies both.
Silencing them would also silence the warning this build exists to give.

## Checks

- `scripts/check-content-parity.sh` — a page added or edited in one language
  only still builds and still renders, and says something different depending
  on which language the reader picked. Edits that genuinely belong to one
  language are declared in `scripts/parity-exceptions.txt`.
- The markdown link check runs over `content/`.
