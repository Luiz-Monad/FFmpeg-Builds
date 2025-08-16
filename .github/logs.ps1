param(
    [switch]$wait,
    [switch]$skipCompleted,
    [string]$repo = "Luiz-Monad/FFmpeg-Builds",
    [string]$workflow = "build.yml"
)

$cookie = Get-Content "gh-cookies.txt" -Raw

function Get-LatestRun {
    $runs = gh run list `
        --workflow "$workflow" `
        --repo "$repo" `
        --limit 1 `
        --json databaseId,status,updatedAt
    ($runs | ConvertFrom-Json)[0]
}

function Get-RunCompareKey($run) {
    if (-not $run) { return "" }
    "$($run.databaseId)-$($run.status)-$($run.updatedAt)"
}

function Get-Run {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $run
    )
    process {
        $runView = gh run view $run.databaseId `
            --json (`
                "databaseId," + `
                "number," + `
                "name," + `
                "displayTitle," + `
                "status," + `
                "conclusion," + `
                "startedAt," + `
                "updatedAt," + `
                "url," + `
                "headBranch," + `
                "headSha")
        $runView | ConvertFrom-Json
    }
}

function Get-RunJobReadIds {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $repo,
        [Parameter(Mandatory=$true)]
        $cookie,
        [Parameter(Mandatory=$true)]
        $run,
        [Parameter(ValueFromPipeline=$true)]
        $job
    )
    begin {
        $jobs = @()
        $realIds = @{}
        $cpu = [int]([Environment]::ProcessorCount)
    }
    process {
        $jobs += ([pscustomobject]@{
            realids = $realIds
            repo = $repo
            cookie = $cookie
            runId = $run.databaseId
            jobId = $_.databaseId
        })
    }
    end {
        $jobs | Foreach-Object -ThrottleLimit $cpu -Parallel {

            function Get-JobRealId($repo, $runId, $jobId) {
                try {
                    $pageUrl = "https://github.com/$repo/actions/runs/$runId/job/$jobId"
                    $page = Invoke-RestMethod -Uri $pageUrl -Headers @{
                        "Cookie" = $_.cookie
                        "Accept" = "text/html"
                        "Accept-Encoding" = "gzip"
                    } -ProgressAction SilentlyContinue
                    $urls = [regex]::Matches($page, '<check-step[^>]*data-job-steps-url="([^"]+)"')
                    $url = $urls | Select-Object -First 1
                    $jobRealId = ($url.groups[1].Value -split "/")[-2]
                    $jobRealId
                } catch {
                    # Write-Host $_
                }
            }
            $_.realIds[$_.jobId] = (Get-JobRealId -repo $_.repo -runId $_.runId -jobId $_.jobId)
        }
        $realIds
    }
}

function Get-RunJobs {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $run
    )
    process {
        $jobs = gh run view $run.databaseId `
            --json "jobs" `
            --jq (".jobs[] | { " + `
                "databaseId: .databaseId, " + `
                "name: .name, " + `
                "status: .status, " + `
                "conclusion: .conclusion, " + `
                "startedAt: .startedAt, " + `
                "completedAt: .completedAt, " + `
                "url: .url" + `
                "}")
        $jobs = $jobs | ConvertFrom-Json
        $realIds = $jobs | Where-Object { 
            $_.conclusion -ne 'skipped'
        } | Get-RunJobReadIds -repo $repo -cookie $cookie -run $run
        $jobs | ForEach-Object {
            $_ | Add-Member -MemberType NoteProperty -Name run -Value $run
            $_ | Add-Member -MemberType NoteProperty -Name realId -Value $realIds[$_.databaseId]
            $_
        }
    }
}

function Get-RunJobStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $run,
        [Parameter(ValueFromPipeline=$true)]
        $job
    )
    process {
        $jobs = gh run view $run.databaseId `
            --json "jobs" `
            --jq (".jobs[] | select( .databaseId == $($job.databaseId) ) | .status")
        $jobs = $jobs | ConvertFrom-Json
        $realIds = $jobs | Where-Object { 
            $_.conclusion -ne 'skipped'
        } | Get-RunJobReadIds -repo $repo -cookie $cookie -run $run
        $jobs | ForEach-Object {
            $_ | Add-Member -MemberType NoteProperty -Name run -Value $run
            $_ | Add-Member -MemberType NoteProperty -Name realId -Value $realIds[$_.databaseId]
            $_
        }
    }
}

function Get-RunJobSteps {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $job
    )
    process {
        $runId = $job.run.databaseId
        $jobRealId = $job.realId
        if (-not $jobRealId) { return }

        $stepsUrl = "https://github.com/$repo/actions/runs/$runId/jobs/$jobRealId/steps?change_id=0"
        Invoke-RestMethod -Uri $stepsUrl -Headers @{
            "Cookie" = $cookie
            "Accept" = "application/json"
            "Accept-Encoding" = "gzip"
        } | ForEach-Object { 
            $pso = [pscustomobject] $_
            $pso | Add-Member -MemberType NoteProperty -Name run -Value $job.run
            $pso | Add-Member -MemberType NoteProperty -Name job -Value $job
            $pso
        }
    }
}

function Get-RunJobStepScrollback {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $step
    )
    process {
        $runId = $step.job.run.databaseId
        $jobRealId = $step.job.realId
        $stepId = $step.id
        if (-not $jobRealId) { return }

        $backscrollUrl = "https://github.com/$repo/actions/runs/$runId/jobs/$jobRealId/steps/$stepId/backscroll"
        Invoke-RestMethod -Uri $backscrollUrl -Headers @{
            "Cookie" = $cookie
            "Accept" = "application/json"
            "Accept-Encoding" = "gzip"
        } | ForEach-Object { 
            $_.lines
        }
    }
}

function Get-RunJobStepLogs {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $step
    )
    process {
        if (-not $step.log_url) { return }

        $logUrl = "https://github.com/$($step.log_url)"
        Invoke-RestMethod -Uri $logUrl -Headers @{
            "Cookie" = $cookie
            "Accept-Encoding" = "gzip"
        }
    }
}

function Get-StatusCompleted {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $items
    )
    process {
        $items | Where-Object { $_.status -eq "completed" }
    }
}

function Get-StatusInProgress {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $items
    )    
    process {
        $items | Where-Object { $_.status -eq "in_progress" }
    }
}

function Get-StatusNotSkipped {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $items
    )
    process {
        $items | Where-Object { $_.status -ne "skipped" }
    }
}

# function Show-RunView($run) {
#     gh run view $run.databaseId --repo "$repo"
# }

# function Show-RunLogs($run) {
#     gh run view $run.databaseId --repo "$repo" --log
# }

function Show-Run {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $run
    )
    process {    
        $run | `
            Format-List | `
            Out-Host
    }
}

function Show-RunJobs {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $job
    )
    begin {
        $jobs = @()
    }
    process {
        $jobs += $job
    } 
    end {
        $jobs | `
            Select-Object startedAt, status, conclusion, name, completedAt | `
            Format-Table | `
            Out-Host
    }
}

function Show-RunJob {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $job
    )    
    process {
        $job | `
            Format-List | `
            Out-Host
    }
}

function Show-RunJobSteps {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $step
    )
    begin {
        $steps = @()
    }
    process {
        $steps += $step
    } 
    end {
        $steps | `
            Select-Object startedAt, status, conclusion, number, name, completedAt | `
            Format-Table | `
            Out-Host
    }
}

function Show-RunJobStep {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $step
    )
    process {
        $step | `
            Format-List | `
            Out-Host
    }
}

function Show-RunJobStepLogs {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $step
    )
    begin {
        $steps = @()
    }
    process {
        $steps += $step
    } 
    end {
        $steps |
            Format-Table | `
            Out-Host
    }
}

function Invoke-RunJobStepRealtimeLogs {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true)]
        $step
    )
    process {
        $seen = @{}

        $div = "".PadLeft($Host.UI.RawUI.WindowSize.Width, "-")
        Write-Host -ForegroundColor Cyan "$div`nStreaming realtime logs for step: $($step.number)-$($step.name)`n$div"

        while ($true) {
            $scrollback = $step | Get-RunJobStepScrollback 
            foreach ($line in $scrollback) {
                if (-not $seen.ContainsKey($line.id)) {
                    $seen[$line.id] = $true
                    Write-Host $line.line
                }
            }

            # stop if job completed
            $status = $step.job | Get-RunJobStatus -run $step.run
            if ($status -eq "completed") {
                Write-Host -ForegroundColor Cyan "$div`nJob completed with conclusion: $($job.conclusion)`n$div"
                break
            }

            Start-Sleep -Seconds 1
        }
    }
}

$script:prevRun = $null

function Invoke-LogReport {
    $currentRun = Get-LatestRun
    if ((Get-RunCompareKey $currentRun) -eq (Get-RunCompareKey $script:prevRun)) { return }

    $div = "".PadLeft($Host.UI.RawUI.WindowSize.Width, "=")
    Write-Host -ForegroundColor Cyan "$div`nRun $($currentRun.databaseId) Logs`n$div"
    # Show-RunView $currentRun

    $div = "".PadLeft($Host.UI.RawUI.WindowSize.Width, "-")
    # Write-Host -ForegroundColor Cyan "$div"
    # Show-RunLogs $currentRun
    # Write-Host -ForegroundColor Cyan "$div"

    $currentRun | Get-Run | Show-Run
    $jobs = $currentRun | Get-RunJobs
    $jobs | Show-RunJobs

    if (-not $skipCompleted) {
        $jobs | Get-StatusCompleted | ForEach-Object {
            $job = $_
            $steps = $job | Get-RunJobSteps

            Write-Host -ForegroundColor Cyan "$div"
            $job | Show-RunJob
            Write-Host -ForegroundColor DarkGreen "$div"
            $steps | Show-RunJobSteps

            $steps | Get-StatusCompleted | Get-StatusNotSkipped | ForEach-Object {
                $step = $_

                $step | Show-RunJobStep
                $step | Get-RunJobStepLogs | Show-RunJobStepLogs            
                Write-Host -ForegroundColor DarkGreen "$div"
            }
        }
    }

    $jobs | Get-StatusInProgress | ForEach-Object {
        $job = $_
        $steps = $job | Get-RunJobSteps
        
        Write-Host -ForegroundColor Cyan "$div"
        $job | Show-RunJob
        Write-Host -ForegroundColor DarkGreen "$div"
        $steps | Show-RunJobSteps

        if (-not $skipCompleted) {
            $steps | Get-StatusCompleted | Get-StatusNotSkipped | ForEach-Object {
                $step = $_

                $step | Show-RunJobStep
                $step | Get-RunJobStepLogs | Show-RunJobStepLogs
                Write-Host -ForegroundColor DarkGreen "$div"
            }
        }
        
        $steps | Get-StatusInProgress | ForEach-Object {
            $step = $_

            $step | Show-RunJobStep
            $step | Invoke-RunJobStepRealtimeLogs
            Write-Host -ForegroundColor DarkGreen "$div"
            $step | Get-RunJobStepLogs | Show-RunJobStepLogs
            Write-Host -ForegroundColor DarkGreen "$div"
        }
    }

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
