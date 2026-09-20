#!pwsh

function ConvertFrom-GpgSecretKeyListing {
    <#
    .SYNOPSIS
      Turn `gpg --list-secret-keys --with-colons` output into one line per key.

    .DESCRIPTION
      Each `sec` record carries the long key id in field 5; the `uid` record
      that follows carries the user id in field 10. Returns "<keyid>  <uid>"
      per secret key, in listing order, so a picker shows who each key is
      without the caller parsing colon records. An empty listing yields
      nothing.
    #>
    param([Parameter(Mandatory)][AllowEmptyCollection()][string[]]$Lines)
    $keyId = $null
    foreach ($line in $Lines) {
        $fields = $line -split ':'
        switch ($fields[0]) {
            'sec' { $keyId = $fields[4] }
            'uid' { if ($keyId) { "$keyId  $($fields[9])"; $keyId = $null } }
        }
    }
}

function ConvertTo-SigningKeyValue {
    <#
    .SYNOPSIS
      Take the key id off a picked "<keyid>  <uid>" line.

    .DESCRIPTION
      Returns the first token of the line with surrounding whitespace removed,
      which is the value git's user.signingkey takes for an OpenPGP key. An
      empty or whitespace-only line — what fzf returns on cancel — yields
      $null so the caller can distinguish a cancel from a choice.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string]$PickedLine)
    if ([string]::IsNullOrWhiteSpace($PickedLine)) { return $null }
    return ($PickedLine.Trim() -split '\s+')[0]
}

function Set-GitSigningKey {
    <#
    .SYNOPSIS
      Pick a GPG secret key with fzf and declare it for the current repository.

    .DESCRIPTION
      Lists the secret keys in the local GPG keyring and writes the chosen
      key id as this repository's user.signingkey. Cancelling the selection
      writes nothing. Prints the resulting setting so the declaration is
      visible in the transcript.
    #>
    $choices = ConvertFrom-GpgSecretKeyListing @(gpg --list-secret-keys --with-colons --keyid-format long)
    $line = $choices | fzf --prompt 'signing key> '
    $value = ConvertTo-SigningKeyValue "$line"
    if (-not $value) { return }
    git config user.signingkey $value
    git config user.signingkey
}
