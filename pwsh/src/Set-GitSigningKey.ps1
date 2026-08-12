#!pwsh

function ConvertTo-SigningKeyValue {
    <#
    .SYNOPSIS
      Wrap an OpenSSH public-key line as a git user.signingkey literal.

    .DESCRIPTION
      Returns "key::<line>" with surrounding whitespace removed, the form git
      accepts when the key lives in an agent rather than in a file. An empty
      or whitespace-only line — what fzf returns on cancel — yields $null so
      the caller can distinguish a cancel from a choice.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string]$PublicKeyLine)
    if ([string]::IsNullOrWhiteSpace($PublicKeyLine)) { return $null }
    return "key::$($PublicKeyLine.Trim())"
}

function Set-GitSigningKey {
    <#
    .SYNOPSIS
      Pick a signing key from the SSH agent with fzf and declare it for the
      current repository.

    .DESCRIPTION
      Lists the public keys the agent serves (on this machine: the Bitwarden
      vault) and writes the chosen one as this repository's user.signingkey.
      Cancelling the selection writes nothing. Prints the resulting setting
      so the declaration is visible in the transcript.
    #>
    $line = ssh-add -L | fzf --prompt 'signing key> '
    $value = ConvertTo-SigningKeyValue "$line"
    if (-not $value) { return }
    git config user.signingkey $value
    git config user.signingkey
}
