$region="us-east-1"
$account="474150620111"
$repo="flask-app"

$ecr="$account.dkr.ecr.$region.amazonaws.com/$repo"

# Login
aws ecr get-login-password --region $region |
docker login --username AWS --password-stdin $account.dkr.ecr.$region.amazonaws.com

# Tag (IMPORTANT: include :latest)
docker tag flask-app:latest $ecr:latest

# Push (IMPORTANT: include :latest)
docker push $ecr:latest
