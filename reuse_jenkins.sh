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

    run_remote_command "$user" "$host" "sudo su - jenkins -c 'ssh-keygen -t rsa'"
}

# Copy SSH Public Key from Master to Slave
copy_ssh_public_key() {
    local master_user=$1
    local master_host=$2
    local slave_user=$3
    local slave_host=$4

    MASTER_SSH_PUBLIC_KEY=$(run_remote_command "$master_user" "$master_host" "sudo cat /var/lib/jenkins/.ssh/id_rsa.pub")
    run_remote_command "$slave_user" "$slave_host" "echo \"$MASTER_SSH_PUBLIC_KEY\" | sudo tee -a /var/lib/jenkins/.ssh/authorized_keys"
}

# Verify SSH Connection from Master to Slave
verify_ssh_connection() {
    local master_user=$1
    local master_host=$2
    local slave_user=$3
    local slave_host=$4

    run_remote_command "$master_user" "$master_host" "sudo su - jenkins -c 'ssh $slave_user@$slave_host'"
}

# Install Jenkins on Master
install_jenkins <master_username> <master_ip>

# Generate SSH Keys for Jenkins Master
generate_ssh_keys <master_username> <master_ip>

# Install Jenkins on Slave
install_jenkins <slave_username> <slave_ip>

# Copy Jenkins Master SSH Public Key to Slave
copy_ssh_public_key <master_username> <master_ip> <slave_username> <slave_ip>

# Verify SSH Connection from Master to Slave
verify_ssh_connection <master_username> <master_ip> <slave_username> <slave_ip>

# Exit Jenkins User Shell on Master
run_remote_command <master_username> <master_ip> "exit"
