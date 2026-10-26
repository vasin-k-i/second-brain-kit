<#
  «Второй мозг» — установщик для Windows без bash (PowerShell).
  Качает кит и ставит: папка с заметками, память, команды.

    irm https://raw.githubusercontent.com/vasin-k-i/second-brain-kit/main/install.ps1 | iex

  Если есть Git Bash — лучше основной install.sh: он заодно подключает Codex.
  Путь к заметкам — переменная SB_VAULT (по умолчанию %USERPROFILE%\SecondBrain).
#>
$ErrorActionPreference = "Stop"
$KitUrls = if ($env:SB_KIT_URL) { @($env:SB_KIT_URL) } else { @(
  "https://github.com/vasin-k-i/second-brain-kit/archive/refs/heads/main.tar.gz",
  "https://sb-kit.consul456.workers.dev/sb-lx9wf4cApInIY9VF883j/kit.tar.gz",
  "https://vasinki.ru/sb-lx9wf4cApInIY9VF883j/kit.tar.gz") }
$Dest = Join-Path $env:USERPROFILE ".second-brain-kit"

$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("sbk-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $Tmp | Out-Null
try {
  Write-Host "Скачиваю кит «Второй мозг»…"
  $tar = Join-Path $Tmp "kit.tar.gz"
  $got = $false
  foreach ($u in $KitUrls) {
    try {
      Invoke-WebRequest -Uri $u -OutFile $tar -UseBasicParsing -TimeoutSec 120
      tar -tzf $tar *> $null
      if ($LASTEXITCODE -eq 0) { $got = $true; break }
    } catch { }
    Write-Host "…не открылось: $u — пробую следующий адрес"
  }
  if (-not $got) { throw "Кит не скачался ни с одного адреса. Проверь интернет или VPN и повтори." }
  tar -xzf $tar -C $Tmp
  $inner = Get-ChildItem -LiteralPath $Tmp -Recurse -File -Filter "install.ps1" | Where-Object { $_.Directory.Name -eq "install" } | Select-Object -First 1
  if (-not $inner) { throw "В скачанном архиве нет install\install.ps1" }
  $Src = $inner.Directory.Parent.FullName

  if (Test-Path -LiteralPath $Dest) { Remove-Item -LiteralPath $Dest -Recurse -Force }
  New-Item -ItemType Directory -Force -Path $Dest | Out-Null
  Copy-Item -Path (Join-Path $Src "*") -Destination $Dest -Recurse -Force
  Write-Host "[ok] Кит в $Dest" -ForegroundColor Green

  $vault = if ($env:SB_VAULT) { $env:SB_VAULT } else { Join-Path $env:USERPROFILE "SecondBrain" }
  & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Dest "install\install.ps1") -VaultDir $vault
} finally {
  Remove-Item -LiteralPath $Tmp -Recurse -Force -ErrorAction SilentlyContinue
}
