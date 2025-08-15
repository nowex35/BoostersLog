#!/bin/bash

# ECS Fargate デプロイスクリプト
set -e

# 環境変数
AWS_REGION=${AWS_REGION:-ap-northeast-1}
ECR_REPOSITORY=${ECR_REPOSITORY:-boosterslog-api}
ECS_CLUSTER=${ECS_CLUSTER:-boosterslog-cluster}
ECS_SERVICE=${ECS_SERVICE:-boosterslog-api-service}
ECS_TASK_DEFINITION=${ECS_TASK_DEFINITION:-boosterslog-api}

# アカウントIDを取得
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "🚀 Starting deployment to ECS Fargate..."
echo "Region: $AWS_REGION"
echo "Account ID: $ACCOUNT_ID"
echo "ECR Repository: $ECR_REPOSITORY"
echo "ECS Cluster: $ECS_CLUSTER"
echo "ECS Service: $ECS_SERVICE"

# ECRリポジトリが存在しない場合は作成
echo "📦 Checking ECR repository..."
if ! aws ecr describe-repositories --repository-names $ECR_REPOSITORY --region $AWS_REGION > /dev/null 2>&1; then
    echo "Creating ECR repository: $ECR_REPOSITORY"
    aws ecr create-repository --repository-name $ECR_REPOSITORY --region $AWS_REGION
fi

# ECRにログイン
echo "🔐 Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# イメージをビルドしてプッシュ
echo "🏗️ Building and pushing Docker image..."
cd service
docker build -f Dockerfile.prod -t $ECR_REPOSITORY:latest .
docker tag $ECR_REPOSITORY:latest $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest

# タスク定義を更新
echo "📝 Updating task definition..."
aws ecs register-task-definition \
    --cli-input-json file://ecs-task-definition.json \
    --region $AWS_REGION

# サービスを更新
echo "🔄 Updating ECS service..."
aws ecs update-service \
    --cluster $ECS_CLUSTER \
    --service $ECS_SERVICE \
    --task-definition $ECS_TASK_DEFINITION \
    --region $AWS_REGION

# デプロイ完了を待機
echo "⏳ Waiting for deployment to complete..."
aws ecs wait services-stable \
    --cluster $ECS_CLUSTER \
    --services $ECS_SERVICE \
    --region $AWS_REGION

echo "✅ Deployment completed successfully!"
echo "🌐 Service URL: https://your-load-balancer-url"
