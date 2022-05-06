# get kubeconfig for your cluster
aws eks update-kubeconfig --name k8s --region us-east-2

# add helm charts for secrets storage
helm repo add eks https://aws.github.io/eks-charts
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm repo update
helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver
helm install -n kube-system eks/csi-secrets-store-provider-aws --generate-name

# add loadbalancer policies
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.1/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json

# prepare EKS for loadbalancer
eksctl utils associate-iam-oidc-provider --region=us-east-2 --cluster=k8s --approve
eksctl create iamserviceaccount \
  --cluster=k8s \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name "AmazonEKSLoadBalancerControllerRole" \
  --attach-policy-arn=arn:aws:iam::025563659589:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=k8s \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

# execute below command and copy arn and paste in INSERT_ARN_HERE
aws secretsmanager list-secrets

IAM_POLICY_NAME_SECRET="dbcredentials_secrets_policy_$RANDOM"
IAM_POLICY_ARN_SECRET=$(aws --region "us-east-2" iam \
        create-policy --query Policy.Arn \
    --output text --policy-name $IAM_POLICY_NAME_SECRET \
    --policy-document '{
    "Version": "2012-10-17",
    "Statement": [ {
        "Effect": "Allow",
        "Action": ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        "Resource": ["INSERT_ARN_HERE"]
    } ]
}')

echo $IAM_POLICY_ARN_SECRET | tee -a 00_iam_policy_arn_dbsecret

eksctl create iamserviceaccount --region="us-east-2" --name "todo-deployment-sa" --cluster "k8s" --namespace "todo" --attach-policy-arn "$IAM_POLICY_ARN_SECRET" --approve --override-existing-serviceaccounts

kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml
kubectl --namespace=kube-system get pods -l "app=secrets-store-csi-driver"
