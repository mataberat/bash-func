#!/bin/bash

# Common bash helper functions
function c() { clear; }
function e() { exit; }
function v() { vim "$@"; }
function nv() { nvim "$@"; }
function k() { kubectl "$@"; }
function kc() { kubectx "$@"; }
function kn() { kubens "$@"; }

function dotenv-compare() {
    if [ "$#" -eq 0 ]; then
        echo "Compares two .env files and shows which environment variables are missing in each file"
        echo ""
        echo "Usage:"
        echo "  dotenv-compare <env_file_1> <env_file_2>"
        echo ""
        echo "Examples:"
        echo "  dotenv-compare .env.development .env.production"
        echo "  dotenv-compare .env.local .env.example"
        return 0
    fi

    if [ "$#" -ne 2 ]; then
        echo "Usage: dotenv-compare <env_file_1> <env_file_2>"
        return 1
    fi

    local ENV_FILE_1="$1"
    local ENV_FILE_2="$2"

    if [ ! -f "$ENV_FILE_1" ]; then
        echo "File $ENV_FILE_1 not found!"
        return 1
    fi

    if [ ! -f "$ENV_FILE_2" ]; then
        echo "File $ENV_FILE_2 not found!"
        return 1
    fi

    local keys_file_1
    local keys_file_2
    local missing_in_file_2
    local missing_in_file_1

    keys_file_1=$(awk -F '=' '{print $1}' "$ENV_FILE_1" | sort)
    keys_file_2=$(awk -F '=' '{print $1}' "$ENV_FILE_2" | sort)

    missing_in_file_2=$(comm -23 <(echo "$keys_file_1") <(echo "$keys_file_2"))
    missing_in_file_1=$(comm -13 <(echo "$keys_file_1") <(echo "$keys_file_2"))

    echo "Keys missing in $ENV_FILE_2:"
    echo "$missing_in_file_2"
    echo ""
    echo "Keys missing in $ENV_FILE_1:"
    echo "$missing_in_file_1"
}

# Clean-up aliases
alias docker-cleanup="docker system prune -a -f"
alias awscli-cleanup="unset AWS_ACCESS_KEY_ID && unset AWS_SECRET_ACCESS_KEY && unset AWS_DEFAULT_REGION && unset AWS_REGION && unset AWS_PROFILE && unset AWS_SESSION_TOKEN"

# Git aliases
alias g="git"
alias ga="git add"
alias gs="git status"
alias gco="git checkout"
alias gcm="git commit -m"
alias gd="git diff"
alias gf="git fetch"
alias gp="git pull"
alias gplr="git pull --rebase"
alias gplo="git pull origin"
alias gps="git push"
alias gpo="git push origin"
alias gst="git stash"
alias gstp="git stash pop"
alias gstl="git stash list"
alias gstc="git stash clear"
alias gstsh="git stash show"
alias gbd="git branch -D"
alias gcp="git cherry-pick"
alias gcpm1="git cherry-pick -m 1"

function git-cleanup() { git branch | grep -v "main" | grep -v "master" | xargs git branch -D; }
# Terraform aliases
alias t="terraform"
alias ti="terraform init"
alias tp="terraform plan"
alias ta="terraform apply"
alias td="terraform destroy"
alias to="terraform output"

# Configuration aliases
alias configedit="code ~/.zshrc"
alias configssh="code ~/.ssh/config"

# Common helper functions
function ssh-purge-known-host {
    if [ -z "$1" ]; then
        echo "Usage: ssh-purge-known-host ip=192.168.1.1"
        echo "       ssh-purge-known-host 192.168.1.1"
        return 1
    fi
    local ip="${1#ip=}"
    awk -v ip="$ip" '$1 != ip' ~/.ssh/known_hosts >~/.ssh/known_hosts.tmp && mv ~/.ssh/known_hosts.tmp ~/.ssh/known_hosts
}

# Kubernetes helper functions

function k8s-delete-terminating-namespace() {
    local context namespace
    context=$(kubectl config current-context)
    namespace=$1

    echo "WARNING: This action will forcefully remove all namespaces in Terminating state"
    echo "Kubernetes Context: ${context}"

    if [ -n "$namespace" ]; then
        echo -n "Proceed with cleanup of namespace '$namespace'? (y/N): "
        read -r choice
        case "$choice" in
        y | Y)
            kubectl get ns "$namespace" -ojson | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/$namespace/finalize" -f -
            ;;
        *)
            echo "Operation cancelled"
            return 1
            ;;
        esac
    else
        echo -n "Proceed with cleanup of ALL terminating namespaces? (y/N): "
        read -r choice
        case "$choice" in
        y | Y)
            while IFS= read -r ns; do
                kubectl get ns "$ns" -ojson | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/$ns/finalize" -f -
            done < <(kubectl get ns --field-selector status.phase=Terminating -o jsonpath='{.items[*].metadata.name}')
            ;;
        *)
            echo "Operation cancelled"
            return 1
            ;;
        esac
    fi
}

function k8s-run-alpine-pod() {
    local namespace="${1#namespace=}"
    if [ -z "$namespace" ]; then
        namespace="default"
        echo "INFO: Launching Alpine Linux pod in 'default' namespace"
        echo "NOTE: To target a specific namespace, use: kube-run-alpine namespace=<namespace-name>"
    fi

    kubectl -n "$namespace" run alpine-shell --image=alpine --rm -it -- /bin/sh
    kubectl -n "$namespace" delete pod alpine-shell --grace-period=0 --force || true
}

function k8s-force-delete-pod() {
    local namespace="${1#namespace=}"
    local pod="${2#pod=}"

    if [ -z "$namespace" ] || [ -z "$pod" ]; then
        echo "Usage: kube-force-delete-pod namespace=<namespace-name> pod=<pod-name>"
        echo "       kube-force-delete-pod <namespace-name> <pod-name>"
        return 1
    fi

    kubectl delete pod "$pod" -n "$namespace" --grace-period=0 --force
}

function k8s-get-secrets() {
    local namespace="${1#namespace=}"
    local secret="${2#secret=}"
    kubectl -n "$namespace" get secret "$secret" -o jsonpath="{.data}" | jq 'map_values(@base64d)'
}
