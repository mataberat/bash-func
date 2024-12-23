#!/bin/bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Set default editor for kubectl
# export EDITOR="code --wait"
# export KUBE_EDITOR="code --wait"
export EDITOR="nvim"
export KUBE_EDITOR="nvim"

# Disable Ansible Python warnings
export PYTHONWARNINGS="ignore"

# Disable Terraform output color
export NO_COLOR="1"
