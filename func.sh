#!/bin/bash

# Common bash helper functions
function c() { clear; }
function e() { exit; }
function v() { vim "$@"; }
function nv() { nvim "$@"; }
function k() { kubectl "$@"; }
function kc() { kubectx "$@"; }
function kn() { kubens "$@"; }

# Git helper functions
function g() { git "$@"; }
function ga() { git add "$@"; }
function gs() { git status; }
function gco() { git checkout "$@"; }
function gcm() { git commit -m "$@"; }
function gd() { git diff "$@"; }
function gf() { git fetch "$@"; }
function gp() { git pull; }
function gplr() { git pull --rebase; }
function gplo() { git pull origin "$@"; }
function gps() { git push "$@"; }
function gpo() { git push origin "$@"; }
function gst() { git stash; }
function gstp() { git stash pop; }
function gstl() { git stash list; }
function gstc() { git stash clear; }
function gstsh() { git stash show; }
function git-cleanup() { git branch | grep -v "main" | grep -v "master" | xargs git branch -D; }
function gbd() { git branch -D "$@"; }

# Terraform helper functions
function tf() { terraform "$@"; }
function tfp() { terraform plan; }
function tfa() { terraform apply; }
function tfd() { terraform destroy; }
function tfi() { terraform init; }
function tfo() { terraform output; }

# Configuration edit
function configedit() { code ~/.zshrc; }
function configssh() { code ~/.ssh/config; }

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