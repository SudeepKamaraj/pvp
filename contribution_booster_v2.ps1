
# contribution_booster_v2.ps1
# This script generates random commits for the past 3 months, 
# SKIPPING January 2nd (Jan 5-11) and 3rd week (Jan 12-18).

$daysToLookBack = 90
$maxCommitsPerDay = 5
$filename = "CONTRIBUTIONS.md"

# Clear or ensure the file exists
New-Item -ItemType File -Path $filename -Force

$startDate = (Get-Date).AddDays(-$daysToLookBack)
$today = Get-Date

Write-Host "Starting contribution generation (Skipping Jan Week 2 & 3)..." -ForegroundColor Cyan

for ($i = 0; $i -le $daysToLookBack; $i++) {
    $currentDate = $startDate.AddDays($i)
    
    # Check if in January week 2 (Jan 5-11) or week 3 (Jan 12-18)
    $isJanWeek2 = ($currentDate -ge (Get-Date -Year 2026 -Month 1 -Day 5 -Hour 0 -Minute 0 -Second 0)) -and ($currentDate -le (Get-Date -Year 2026 -Month 1 -Day 11 -Hour 23 -Minute 59 -Second 59))
    $isJanWeek3 = ($currentDate -ge (Get-Date -Year 2026 -Month 1 -Day 12 -Hour 0 -Minute 0 -Second 0)) -and ($currentDate -le (Get-Date -Year 2026 -Month 1 -Day 18 -Hour 23 -Minute 59 -Second 59))
    
    if ($isJanWeek2 -or $isJanWeek3) {
        Write-Host "Skipping specific January date: $($currentDate.ToShortDateString())" -ForegroundColor Yellow
        continue
    }

    # Random number of commits for this day (0 to $maxCommitsPerDay)
    $numCommits = Get-Random -Minimum 0 -Maximum ($maxCommitsPerDay + 1)
    
    if ($numCommits -gt 0) {
        Write-Host "Adding $numCommits commits for $($currentDate.ToShortDateString())" -ForegroundColor Green
        
        for ($j = 1; $j -le $numCommits; $j++) {
            $hour = Get-Random -Minimum 9 -Maximum 21
            $minute = Get-Random -Minimum 0 -Maximum 60
            $second = Get-Random -Minimum 0 -Maximum 60
            
            $batchDate = Get-Date -Year $currentDate.Year -Month $currentDate.Month -Day $currentDate.Day -Hour $hour -Minute $minute -Second $second
            $formattedDate = $batchDate.ToString("yyyy-MM-ddTHH:mm:ss")
            
            $env:GIT_AUTHOR_DATE = $formattedDate
            $env:GIT_COMMITTER_DATE = $formattedDate
            
            Add-Content -Path $filename -Value "Contribution on $formattedDate"
            git add $filename
            git commit -m "docs: update contributions log for $formattedDate" --quiet
        }
    }
}

Remove-Item Env:\GIT_AUTHOR_DATE
Remove-Item Env:\GIT_COMMITTER_DATE

Write-Host "Done! History rewritten without Jan Week 2 & 3." -ForegroundColor Cyan
