#!/bin/bash
# This shebang tells the system to execute the script using the Bash shell

dnf update -y
dnf install -y amazon-ssm-agent

# Enable the SSM Agent to start automatically on system boot
# This ensures that the agent will always run after every reboot
systemctl enable amazon-ssm-agent

# Start the SSM Agent service immediately
# This activates the agent right now, so SSM becomes available right after launch
systemctl start amazon-ssm-agent
