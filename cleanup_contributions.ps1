
# cleanup_contributions.ps1
# 1. Reset to the base commit
git reset --hard 5c3ca78

# 2. Run the updated booster (which skips the requested weeks)
.\contribution_booster_v2.ps1

# 3. Cherry-pick the "good" manual commit
git cherry-pick 98c99ba

# 4. Force push
git push origin main --force
