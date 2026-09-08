$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { throw "Install Flutter 3.29.3 first." }
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
try {
  flutter create --project-name pazel --org ir.pazel --platforms=android,ios,web "$temp/pazel"
  if ($LASTEXITCODE -ne 0) { throw "flutter create failed" }
  python scripts/merge_platforms.py "$temp/pazel"
  if ($LASTEXITCODE -ne 0) { throw "platform merge failed" }
  flutter pub get
  if ($LASTEXITCODE -ne 0) { throw "dependency resolution failed" }
} finally {
  if (Test-Path $temp) { Remove-Item -Recurse -Force $temp }
}
