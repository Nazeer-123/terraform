#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# --- Configuration for SonarQube ---
# SonarQube requires specific kernel parameters for max_map_count to run correctly
sudo sysctl -w vm.max_map_count=262144

# --- 1. Install Jenkins ---
# Ports: 8080 (UI), 50000 (Agent connections)
# Volume: jenkins_home for persistent job configuration and data
sudo docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts-jdk11

# --- 2. Install SonarQube ---
# Port: 9000 (UI)
# Volume: sonarqube_data for persistence
sudo docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  sonarqube:lts

# --- 3. Install Nexus Repository (Artifact Repository) ---
# Port: 8081 (UI/API)
# Volume: nexus_data for persistent artifacts and configuration
sudo docker run -d \
  --name nexus \
  -p 8081:8081 \
  -v nexus_data:/nexus-data \
  --shm-size=512m \
  sonatype/nexus3