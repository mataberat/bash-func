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
# Git aliases
alias g="git"
alias ga="git add"
alias gs="git status"
alias gco="git checkout"
alias gcommit="git commit -m"
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

function git-cleanup() { git branch | grep -v "main" | grep -v "master" | xargs git branch -D; }
# Terraform aliases
alias tf="terraform"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfd="terraform destroy"
alias tfi="terraform init"
alias tfo="terraform output"
# Configuration edit
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
    local context
    context=$(kubectl config current-context)
    echo "WARNING: This action will forcefully remove all namespaces in Terminating state"
    echo "Kubernetes Context: ${context}"
    read -r -p "Proceed with namespace cleanup? (y/N): " choice
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
