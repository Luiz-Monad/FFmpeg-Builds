gh run list --json databaseId,number,name,displayTitle,status | convertfrom-json | ? number -gt 200 | % { gh run delete $_.databaseId } 
