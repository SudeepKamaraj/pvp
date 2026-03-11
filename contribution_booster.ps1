
# contribution_booster.ps1
# This script generates random commits for the past 3 months to boost your GitHub contribution graph.

$daysToLookBack = 90
$maxCommitsPerDay = 5
$filename = "CONTRIBUTIONS.md"

# Ensure the file exists
if (-not (Test-Path $filename)) {
    New-Item -ItemType File -Path $filename -Force
}

$startDate = (Get-Date).AddDays(-$daysToLookBack)
$today = Get-Date

Write-Host "Starting contribution generation from $($startDate.ToShortDateString()) to $($today.ToShortDateString())..." -ForegroundColor Cyan

for ($i = 0; $i -le $daysToLookBack; $i++) {
    $currentDate = $startDate.AddDays($i)
    
    # Random number of commits for this day (0 to $maxCommitsPerDay)
    $numCommits = Get-Random -Minimum 0 -Maximum ($maxCommitsPerDay + 1)
    
    if ($numCommits -gt 0) {
        Write-Host "Adding $numCommits commits for $($currentDate.ToShortDateString())" -ForegroundColor Green
        
        for ($j = 1; $j -le $numCommits; $j++) {
            # Add some randomness to the hour/minute
            $hour = Get-Random -Minimum 9 -Maximum 21
            $minute = Get-Random -Minimum 0 -Maximum 60
            $second = Get-Random -Minimum 0 -Maximum 60
            
            $batchDate = Get-Date -Year $currentDate.Year -Month $currentDate.Month -Day $currentDate.Day -Hour $hour -Minute $minute -Second $second
            # Format in ISO 8601 for Git
            $formattedDate = $batchDate.ToString("yyyy-MM-ddTHH:mm:ss")
            
            # Set environment variables for backdating
            $env:GIT_AUTHOR_DATE = $formattedDate
            $env:GIT_COMMITTER_DATE = $formattedDate
            
            # Make a change to the file
            Add-Content -Path $filename -Value "Contribution on $formattedDate"
            
            # Stage and commit
            git add $filename
            git commit -m "docs: update contributions log for $formattedDate" --quiet
        }
    } else {
        Write-Host "Skipping $($currentDate.ToShortDateString()) (0 commits)" -ForegroundColor Gray
    }
}

# Clean up environment variables
Remove-Item Env:\GIT_AUTHOR_DATE
Remove-Item Env:\GIT_COMMITTER_DATE

Write-Host "Done! You now have consistent green squares for the past 3 months." -ForegroundColor Cyan
Write-Host "To see them on GitHub, run: git push origin main" -ForegroundColor Yellow
