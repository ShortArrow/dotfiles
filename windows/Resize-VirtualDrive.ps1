function Resize-VirtualDrive
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, HelpMessage = "Specify the full path to the VHDX file.")]
    [string]$Path,

    [Parameter(Mandatory = $true, HelpMessage = "Specify the new total size (e.g., 300GB, 400GB).")]
    [int64]$SizeBytes,

    [Parameter(Mandatory = $true, HelpMessage = "Specify the target drive letter (a single character).")]
    [ValidateLength(1, 1)]
    [string]$DriveLetter
  )

  process
  {
    try
    {
      # 1. Resize the VHDX file
      Write-Host "[1/3] Expanding VHDX file: $Path -> $($SizeBytes / 1GB) GB" -ForegroundColor Cyan
      Resize-VHD -Path $Path -SizeBytes $SizeBytes

      # 2. Update storage cache (force OS to recognize the new size)
      Write-Host "[2/3] Updating host storage cache..." -ForegroundColor Cyan
      Update-HostStorageCache
      Start-Sleep -Seconds 1 # Brief buffer for the OS to catch up

      # 3. Extend the partition
      Write-Host "[3/3] Extending file system for drive $(${DriveLetter}:) to maximum available size..." -ForegroundColor Cyan
      $partition = Get-Partition -DriveLetter $DriveLetter
      $maxSize = (Get-PartitionSupportedSize -DriveLetter $DriveLetter).SizeMax

      $partition | Resize-Partition -Size $maxSize

      # Output results
      Write-Host "`n[Success] Virtual drive expansion completed successfully." -ForegroundColor Green
      Get-Volume -DriveLetter $DriveLetter
    } catch
    {
      Write-Error "An error occurred during the execution: $_"
    }
  }
}
