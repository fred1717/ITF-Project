#!/bin/bash
# Amazon Linux 2023 uses DNF as its default package manager

# Update the system
dnf update -y

# Start and enable the SSM agent (already pre-installed in AL2023)
systemctl enable --now amazon-ssm-agent

# Wait briefly and check the agent status (for debugging/logging)
sleep 5
systemctl status amazon-ssm-agent
