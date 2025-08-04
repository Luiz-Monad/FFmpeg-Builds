param(
    [switch]$wait,
    [string]$repo = "Luiz-Monad/FFmpeg-Builds",
    [string]$workflow = "build.yml"
)

function Get-LatestRun {
    $runs = gh run list --workflow "$workflow" --repo "$repo" --limit 1 --json databaseId,status
    ($runs | ConvertFrom-Json)[0]
}

function Get-RunCompareKey($run) {
    if (-not $run) { return "" }
    "$($run.databaseId)-$($run.status)"
}

function Get-RunView($run) {
    gh run view $run.databaseId --repo "$repo"
}

function Get-RunLogs($run) {
    gh run view $run.databaseId --repo "$repo" --log
}

$script:prevRun = $null

function Invoke-LogReport {
    $currentRun = Get-LatestRun
    if ((Get-RunCompareKey $currentRun) -eq (Get-RunCompareKey $script:prevRun)) { return }
    $div = "".PadLeft($Host.UI.RawUI.WindowSize.Width, "=")
    Write-Host -ForegroundColor Cyan "$div`nRun $($currentRun.databaseId) Logs`n$div"
    $div = "".PadLeft($Host.UI.RawUI.WindowSize.Width, "=")
    Get-RunView $currentRun
    $div = "".PadLeft($Host.UI.RawUI.WindowSize.Width, "-")
    Get-RunLogs $currentRun
    $script:prevRun = $currentRun
}

Invoke-LogReport

if ($wait) {
    while ($true) {
        try {
            Invoke-LogReport
            Start-Sleep -Seconds 5
        } catch {
            Write-Host "Error: $_"
        }
    }
}
