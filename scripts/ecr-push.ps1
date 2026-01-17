param(
  [Parameter(Mandatory=$true)][string]$Region,
  [Parameter(Mandatory=$true)][string]$AccountId,
  [Parameter(Mandatory=$true)][string]$RepoName,
  [string]$Tag = "latest"
)

$repoUri = "${AccountId}.dkr.ecr.${Region}.amazonaws.com/${RepoName}"

docker build -t "${RepoName}:${Tag}" .
docker tag  "${RepoName}:${Tag}" "${repoUri}:${Tag}"
docker push "${repoUri}:${Tag}"

Write-Host "Pushed: ${repoUri}:${Tag}"
