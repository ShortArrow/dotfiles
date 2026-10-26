#!/usr/bin/env bash
# Shared by the pre-commit hook beside it and by git unlock (../unlock.sh).
#
# Kana lock left on turns the passphrase typed into pinentry into half-width
# kana, and gpg refuses it without saying why. clear_kana_lock turns it off
# through the KanaLock module before gpg is asked to sign, and says so on
# stderr, prefixed with the caller's name, when it was on.
#
# pwsh costs about half a second to start, so it is started only where it can
# matter: Windows, the module installed, and the desk's keyboard rather than
# an SSH session's.

kana_lock_module_installed() {
  [ -d "$(cygpath -O)/PowerShell/Modules/KanaLock" ] ||
    [ -d "$(cygpath -F 38)/PowerShell/Modules/KanaLock" ]
}

clear_kana_lock() {
  case ${OSTYPE:-} in
    msys* | cygwin*) ;;
    *) return 0 ;;
  esac
  [ -z "${SSH_CONNECTION:-}" ] || return 0
  kana_lock_module_installed || return 0
  pwsh -NoProfile -NonInteractive -Command \
    "if (Get-KanaLock) { Disable-KanaLock; [Console]::Error.WriteLine('$1: kana lock was on; turned it off') }"
}
