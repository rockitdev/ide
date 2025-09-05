#!/bin/bash

# Cloud and DevOps Tools
# Part of the Portable Neovim IDE Dotfiles

# ============================================================================
# CLOUD PROVIDER HELPERS
# ============================================================================

# AWS CLI helpers
aws_profile() {
    local profile="${1:-}"
    
    if [ -z "$profile" ]; then
        echo "Available AWS profiles:"
        aws configure list-profiles
        echo -e "\nCurrent profile: $AWS_PROFILE"
    else
        export AWS_PROFILE="$profile"
        echo "Switched to AWS profile: $profile"
        aws sts get-caller-identity
    fi
}

aws_regions() {
    aws ec2 describe-regions --output table
}

aws_instances() {
    local region="${1:-us-east-1}"
    aws ec2 describe-instances \
        --region "$region" \
        --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,Tags[?Key==`Name`]|[0].Value]' \
        --output table
}

aws_s3_ls() {
    local bucket="$1"
    
    if [ -z "$bucket" ]; then
        aws s3 ls
    else
        aws s3 ls "s3://$bucket" --recursive --human-readable --summarize
    fi
}

aws_logs() {
    local group="${1:-/aws/lambda}"
    local stream="${2:-}"
    
    if [ -z "$stream" ]; then
        aws logs describe-log-streams --log-group-name "$group" --order-by LastEventTime --descending --limit 10
    else
        aws logs tail "$group" --follow --log-stream-names "$stream"
    fi
}

# GCP helpers
gcp_project() {
    local project="${1:-}"
    
    if [ -z "$project" ]; then
        gcloud projects list
        echo -e "\nCurrent project: $(gcloud config get-value project)"
    else
        gcloud config set project "$project"
        echo "Switched to GCP project: $project"
    fi
}

gcp_instances() {
    gcloud compute instances list
}

gcp_logs() {
    local filter="${1:-severity>=ERROR}"
    gcloud logging read "$filter" --limit=50 --format=json | jq -r '.[] | "\(.timestamp) [\(.severity)] \(.jsonPayload.message // .textPayload)"'
}

# Azure helpers
azure_sub() {
    local subscription="${1:-}"
    
    if [ -z "$subscription" ]; then
        az account list --output table
    else
        az account set --subscription "$subscription"
        echo "Switched to Azure subscription: $subscription"
        az account show
    fi
}

azure_vms() {
    az vm list --output table
}

azure_resources() {
    az resource list --output table
}

# ============================================================================
# KUBERNETES HELPERS
# ============================================================================

# Kubernetes context management
k8s_context() {
    local context="${1:-}"
    
    if [ -z "$context" ]; then
        kubectl config get-contexts
    else
        kubectl config use-context "$context"
        echo "Switched to context: $context"
        kubectl get nodes
    fi
}

# Kubernetes namespace switcher
k8s_ns() {
    local namespace="${1:-}"
    
    if [ -z "$namespace" ]; then
        kubectl get namespaces
        echo -e "\nCurrent namespace: $(kubectl config view --minify --output 'jsonpath={..namespace}')"
    else
        kubectl config set-context --current --namespace="$namespace"
        echo "Switched to namespace: $namespace"
    fi
}

# Pod management
k8s_pods() {
    local namespace="${1:---all-namespaces}"
    kubectl get pods "$namespace" -o wide
}

k8s_exec() {
    local pod="${1:-$(kubectl get pods --no-headers | fzf | awk '{print $1}')}"
    local container="${2:-}"
    local command="${3:-/bin/bash}"
    
    if [ -n "$container" ]; then
        kubectl exec -it "$pod" -c "$container" -- "$command"
    else
        kubectl exec -it "$pod" -- "$command"
    fi
}

k8s_logs() {
    local pod="${1:-$(kubectl get pods --no-headers | fzf | awk '{print $1}')}"
    local container="${2:-}"
    
    if [ -n "$container" ]; then
        kubectl logs -f "$pod" -c "$container"
    else
        kubectl logs -f "$pod" --all-containers=true
    fi
}

k8s_port_forward() {
    local pod="${1:-$(kubectl get pods --no-headers | fzf | awk '{print $1}')}"
    local ports="${2:-8080:80}"
    
    echo "Port forwarding $pod ($ports)"
    kubectl port-forward "$pod" "$ports"
}

# Helm helpers
helm_search() {
    local chart="${1:-}"
    helm search repo "$chart"
}

helm_upgrade() {
    local release="$1"
    local chart="$2"
    local values="${3:-values.yaml}"
    
    if [ -z "$release" ] || [ -z "$chart" ]; then
        echo "Usage: helm_upgrade <release> <chart> [values-file]"
        return 1
    fi
    
    helm upgrade "$release" "$chart" -f "$values" --install --wait
}

# ============================================================================
# TERRAFORM HELPERS
# ============================================================================

# Terraform workspace management
tf_workspace() {
    local workspace="${1:-}"
    
    if [ -z "$workspace" ]; then
        terraform workspace list
    else
        terraform workspace select "$workspace" || terraform workspace new "$workspace"
        echo "Switched to workspace: $workspace"
    fi
}

# Terraform plan with output
tf_plan() {
    local var_file="${1:-terraform.tfvars}"
    
    terraform fmt -recursive
    terraform validate
    terraform plan -var-file="$var_file" -out=tfplan
}

# Terraform apply with confirmation
tf_apply() {
    if [ -f "tfplan" ]; then
        terraform apply tfplan
        rm tfplan
    else
        echo "No plan file found. Run tf_plan first."
    fi
}

# Terraform state management
tf_state() {
    local action="${1:-list}"
    
    case "$action" in
        list)
            terraform state list
            ;;
        show)
            local resource="${2:-}"
            terraform state show "$resource"
            ;;
        rm)
            local resource="${2:-}"
            terraform state rm "$resource"
            ;;
        *)
            echo "Usage: tf_state [list|show|rm] [resource]"
            ;;
    esac
}

# ============================================================================
# DOCKER & CONTAINER REGISTRY
# ============================================================================

# Docker registry management
docker_registry() {
    local registry="${1:-docker.io}"
    local action="${2:-login}"
    
    case "$action" in
        login)
            docker login "$registry"
            ;;
        list)
            if [ "$registry" = "ecr" ]; then
                aws ecr describe-repositories
            elif [ "$registry" = "gcr" ]; then
                gcloud container images list
            elif [ "$registry" = "acr" ]; then
                az acr repository list
            fi
            ;;
        push)
            local image="${3:-}"
            docker push "$registry/$image"
            ;;
        *)
            echo "Usage: docker_registry <registry> [login|list|push] [image]"
            ;;
    esac
}

# Docker cleanup
docker_cleanup() {
    echo "🧹 Cleaning up Docker resources..."
    
    # Remove stopped containers
    docker container prune -f
    
    # Remove unused images
    docker image prune -a -f
    
    # Remove unused volumes
    docker volume prune -f
    
    # Remove unused networks
    docker network prune -f
    
    echo "✅ Docker cleanup completed"
}

# Container security scan
container_scan() {
    local image="${1:-}"
    
    if [ -z "$image" ]; then
        echo "Usage: container_scan <image>"
        return 1
    fi
    
    if command -v trivy &> /dev/null; then
        trivy image "$image"
    elif command -v grype &> /dev/null; then
        grype "$image"
    else
        echo "Please install trivy or grype for container scanning"
    fi
}

# ============================================================================
# CI/CD HELPERS
# ============================================================================

# GitHub Actions
gh_workflow() {
    local action="${1:-list}"
    local workflow="${2:-}"
    
    case "$action" in
        list)
            gh workflow list
            ;;
        run)
            gh workflow run "$workflow"
            ;;
        view)
            gh run list --workflow="$workflow"
            ;;
        logs)
            local run_id="${3:-$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')}"
            gh run view "$run_id" --log
            ;;
        *)
            echo "Usage: gh_workflow [list|run|view|logs] [workflow] [run-id]"
            ;;
    esac
}

# GitLab CI
gitlab_pipeline() {
    local project="${1:-$(git remote get-url origin | sed 's/.*://;s/\.git$//')}"
    local action="${2:-list}"
    
    case "$action" in
        list)
            glab ci list
            ;;
        run)
            glab ci run
            ;;
        view)
            glab ci view
            ;;
        *)
            echo "Usage: gitlab_pipeline [project] [list|run|view]"
            ;;
    esac
}

# ============================================================================
# SERVERLESS
# ============================================================================

# Serverless framework helpers
sls_deploy() {
    local stage="${1:-dev}"
    local region="${2:-us-east-1}"
    
    serverless deploy --stage "$stage" --region "$region" --verbose
}

sls_logs() {
    local function="${1:-}"
    local stage="${2:-dev}"
    
    if [ -z "$function" ]; then
        serverless logs --stage "$stage" --tail
    else
        serverless logs -f "$function" --stage "$stage" --tail
    fi
}

sls_invoke() {
    local function="$1"
    local stage="${2:-dev}"
    local data="${3:-'{}'}"
    
    serverless invoke -f "$function" --stage "$stage" --data "$data" --log
}

# ============================================================================
# INFRASTRUCTURE MONITORING
# ============================================================================

# Cloud cost estimation
cloud_cost() {
    local provider="${1:-aws}"
    
    case "$provider" in
        aws)
            aws ce get-cost-and-usage \
                --time-period Start=$(date -u -d '30 days ago' +%Y-%m-%d),End=$(date -u +%Y-%m-%d) \
                --granularity MONTHLY \
                --metrics "UnblendedCost" \
                --group-by Type=DIMENSION,Key=SERVICE
            ;;
        gcp)
            gcloud billing accounts list
            ;;
        azure)
            az consumption usage list --start-date $(date -d '30 days ago' +%Y-%m-%d) --end-date $(date +%Y-%m-%d)
            ;;
        *)
            echo "Unsupported provider: $provider"
            ;;
    esac
}

# Export functions
export -f aws_profile
export -f aws_regions
export -f aws_instances
export -f aws_s3_ls
export -f aws_logs
export -f gcp_project
export -f gcp_instances
export -f gcp_logs
export -f azure_sub
export -f azure_vms
export -f azure_resources
export -f k8s_context
export -f k8s_ns
export -f k8s_pods
export -f k8s_exec
export -f k8s_logs
export -f k8s_port_forward
export -f helm_search
export -f helm_upgrade
export -f tf_workspace
export -f tf_plan
export -f tf_apply
export -f tf_state
export -f docker_registry
export -f docker_cleanup
export -f container_scan
export -f gh_workflow
export -f gitlab_pipeline
export -f sls_deploy
export -f sls_logs
export -f sls_invoke
export -f cloud_cost