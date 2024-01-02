#!/bin/bash

# Function to run commands on a remote machine via SSH
run_remote_command() {
    local user=$1
    local host=$2
    local command=$3
    ssh $user@$host "$command"
}

# Install Jenkins on Master
run_remote_command <master_username> <master_ip> "sudo apt-get update"
run_remote_command <master_username> <master_ip> "sudo apt-get install -y openjdk-11-jre"
run_remote_command <master_username> <master_ip> "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key"
run_remote_command <master_username> <master_ip> "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null"
run_remote_command <master_username> <master_ip> "sudo apt-get update"
run_remote_command <master_username> <master_ip> "sudo apt-get install -y jenkins"
run_remote_command <master_username> <master_ip> "sudo systemctl status jenkins"
run_remote_command <master_username> <master_ip> "sudo systemctl enable jenkins"

# Generate SSH Keys for Jenkins Master
run_remote_command <master_username> <master_ip> "sudo su - jenkins -c 'ssh-keygen -t rsa'"

# Install Jenkins on Slave
run_remote_command <slave_username> <slave_ip> "sudo apt-get update"
run_remote_command <slave_username> <slave_ip> "sudo apt-get install -y openjdk-11-jre"
run_remote_command <slave_username> <slave_ip> "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key"
run_remote_command <slave_username> <slave_ip> "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null"
run_remote_command <slave_username> <slave_ip> "sudo apt-get update"
run_remote_command <slave_username> <slave_ip> "sudo apt-get install -y jenkins"
run_remote_command <slave_username> <slave_ip> "sudo systemctl status jenkins"
run_remote_command <slave_username> <slave_ip> "sudo systemctl enable jenkins"

# Copy Jenkins Master SSH Public Key to Slave
MASTER_SSH_PUBLIC_KEY=$(run_remote_command <master_username> <master_ip> "sudo cat /var/lib/jenkins/.ssh/id_rsa.pub")
run_remote_command <slave_username> <slave_ip> "echo \"$MASTER_SSH_PUBLIC_KEY\" | sudo tee -a /var/lib/jenkins/.ssh/authorized_keys"

# Verify SSH Connection from Master to Slave
run_remote_command <master_username> <master_ip> "sudo su - jenkins -c 'ssh <slave_username>@<slave_ip>'"

# Exit Jenkins User Shell on Master
run_remote_command <master_username> <master_ip> "exit"
