#!/bin/bash

# Function to run commands on a remote machine via SSH
run_remote_command() {
    local user=$1
    local host=$2
    local command=$3
    ssh "$user@$host" "$command"
}

# Install Jenkins on a machine
install_jenkins() {
    local user=$1
    local host=$2

    run_remote_command "$user" "$host" "sudo apt-get update"
    run_remote_command "$user" "$host" "sudo apt-get install -y openjdk-11-jre"
    run_remote_command "$user" "$host" "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key"
    run_remote_command "$user" "$host" "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null"
    run_remote_command "$user" "$host" "sudo apt-get update"
    run_remote_command "$user" "$host" "sudo apt-get install -y jenkins"
    run_remote_command "$user" "$host" "sudo systemctl status jenkins"
    run_remote_command "$user" "$host" "sudo systemctl enable jenkins"
}

# Generate SSH Keys for a user on a machine
generate_ssh_keys() {
    local user=$1
    local host=$2

    run_remote_command "$user" "$host" "ssh-keygen -t rsa"
}

# Copy SSH Public Key from one machine to another
copy_ssh_public_key() {
    local source_user=$1
    local source_host=$2
    local dest_user=$3
    local dest_host=$4

    SOURCE_SSH_PUBLIC_KEY=$(run_remote_command "$source_user" "$source_host" "cat ~/.ssh/id_rsa.pub")
    run_remote_command "$dest_user" "$dest_host" "echo \"$SOURCE_SSH_PUBLIC_KEY\" >> ~/.ssh/authorized_keys"
}

# Install Jenkins on Master
install_jenkins master_user 192.168.1.100

# Generate SSH Keys for Jenkins Master
generate_ssh_keys master_user 192.168.1.100

# Copy Jenkins Master SSH Public Key to Slave
copy_ssh_public_key master_user 192.168.1.100 slave_user 192.168.1.101

# Install Jenkins on Slave
install_jenkins slave_user 192.168.1.101

# Verify SSH Connection from Master to Slave
run_remote_command master_user 192.168.1.100 "ssh slave_user@192.168.1.101 exit"

# Exit Jenkins User Shell on Master
run_remote_command master_user 192.168.1.100 "exit"
