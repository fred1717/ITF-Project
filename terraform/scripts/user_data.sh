#!/bin/bash
# This shebang tells the system to execute the script using the Bash shell

# Install the Amazon SSM Agent using DNF (used on Amazon Linux 2023+)
dnf install -y amazon-ssm-agent
# The '-y' flag automatically answers 'yes' to all prompts to avoid interaction

# Enable the SSM Agent to start automatically on system boot
systemctl enable amazon-ssm-agent
# This ensures that the agent will always run after every reboot

# Start the SSM Agent service immediately
systemctl start amazon-ssm-agent
# This activates the agent right now, so SSM becomes available right after launch
