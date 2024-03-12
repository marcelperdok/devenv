#!/usr/bin/env bash

#
# Asserts that kubectl command is available
#
assertKubectlIsAvailable () {
    local verbose=${1:-0}
    local cmd=kubectl

    assertCommandIsAvailable $cmd
    logDebug "$("$cmd" version --client)" $verbose
}

#
# Asserts that kubelogin command is available
#
assertKubeloginIsAvailable () {
    local verbose=${1:-0}
    local cmd=kubelogin

    assertCommandIsAvailable $cmd
    logDebug "$("$cmd" --version)" $verbose
}

#
# Install kubectl and kubelogin using Azure Cli
# Requires sudo
#
kubeClientInstall () {
   logInfo "Installing kubectl and kubelogin using Azure Cli"

   assertCommandIsAvailable az

   sudo az aks install-cli

   logInfo "Installed kubectl and kubelogin on this system"
}

#
# Install kubectl using apt
# Requires sudo
#
kubectlInstall () {
   logInfo "Installing kubectl version v1.29 on the system using apt"

   # Version in the url can be ignored; the same key is used for signing all repos
   curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg  
   
   # Ensure you select the desired version
   echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

   sudo apt-get update
   sudo apt install kubectl -y

   logInfo "Installed kubectl on this system"
}

#
# Ensure that kubectl is installed on this system
#
ensureKubectlIsInstalled () {
    local package=kubectl
    local installed=$(aptPackageIsInstalled "$package")

    if [ $installed == 0 ]; then
        logInfo "$package is not installed on the system; installing apt package '$package'"
        kubectlInstall
    else
        logInfo "Package '$package' already on the system"
    fi
}

#
# Set up kubectl
#
kubectlSetup () {
    logHeader3 "Setting up kubectl"

    ensureKubectlIsInstalled

    assertCommandIsAvailable kubectl
}

#
# Setup kubectl and kubelogin using Azure Cli
# Requires sudo
#
kubeClientSetup () {
   local verbose=${1:-0}

   logHeader3 "Setting up kubectl and kubelogin using Azure Cli"

   local kubectlAvailable=$(commandIsAvailable kubectl)
   local kubeloginAvailable=$(commandIsAvailable kubelogin)

   if [ $kubectlAvailable == 0 ] || [ $kubeloginAvailable == 0 ]; then
       kubeClientInstall
   else
       logInfo "kubectl and kubelogin are already installed on the system"
   fi

   assertKubectlIsAvailable $verbose
   assertKubeloginIsAvailable $verbose
}
