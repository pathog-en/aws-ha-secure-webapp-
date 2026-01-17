param(
  [Parameter(Mandatory=$true)][string]$Region,
  [Parameter(Mandatory=$true)][string]$AccountId
)

aws ecr get-login-password --region $Region `
| docker login --username AWS --password-stdin "$AccountId.dkr.ecr.$Region.amazonaws.com"
