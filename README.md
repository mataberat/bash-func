# Kubernetes Helper Functions

A collection of powerful shell functions to streamline your Kubernetes workflow.

## Features

- Force delete pods with simple commands
- Clean up stuck namespaces in Terminating state
- Quick access to Alpine Linux debug pods
- Smart shell detection for installation
- Named parameter support for better usability

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/repo/main/install.sh | bash
```

## What's Included

A collection of useful shell function aliases and utilities to improve CLI workflow.

## Common Shortcuts

- `c` - Clear terminal
- `e` - Exit shell
- `v` - Open vim editor
- `nv` - Open neovim editor

## Git Commands

- `g` - Git command alias
- `ga` - Git add
- `gs` - Git status
- `gco` - Git checkout
- `gcm` - Git commit with message
- `gd` - Git diff
- `gf` - Git fetch
- `gp` - Git pull
- `gplr` - Git pull with rebase
- `gplo` - Git pull from origin
- `gps` - Git push
- `gpo` - Git push to origin
- `gst` - Git stash
- `gstp` - Git stash pop
- `gstl` - Git stash list
- `gstc` - Git stash clear
- `gstsh` - Git stash show
- `git-cleanup` - Delete all branches except main/master
- `gbd` - Git branch delete

## Terraform Commands

- `tf` - Terraform command alias
- `tfp` - Terraform plan
- `tfa` - Terraform apply
- `tfd` - Terraform destroy
- `tfi` - Terraform init
- `tfo` - Terraform output

## Kubernetes Commands

- `k` - kubectl alias
- `kc` - kubectx alias
- `kn` - kubens alias
- `k8s-delete-terminating-namespace` - Force delete stuck namespaces
- `k8s-run-alpine-pod` - Run temporary Alpine Linux pod
- `k8s-force-delete-pod` - Force delete a pod

## Configuration Helpers

- `configedit` - Edit .zshrc in VS Code
- `configssh` - Edit SSH config in VS Code
- `ssh-purge-known-host` - Remove entry from known_hosts file
