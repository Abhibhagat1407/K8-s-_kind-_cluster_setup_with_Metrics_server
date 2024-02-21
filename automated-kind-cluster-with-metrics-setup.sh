#!/bin/bash

set -e  # Exit immediately if any command returns a non-zero exit status

file_to_search="kind-config.yml"
full_path="$(pwd)/$file_to_search"  # Corrected syntax

echo "Current directory: $(pwd)"
echo "File to search: $file_to_search"
echo "Full path to file: $full_path"


if [ -f "$file_to_search" ]; then
        echo "conf file is available and executing it.. "

	echo "Enter your desired cluster name:"
	read name

        kind create cluster --name $name --config $file_to_search


	echo "Testing if Kind cluster is running or not:"
        kubectl get nodes


	 echo "Metrics server configuration started...."

        echo "Applying metrics server components:"
        kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml

        echo "Patching metrics server deployment:"
        kubectl patch -n kube-system deployment metrics-server --type=json \
          -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

        echo "Kind is up and running"





else
        echo "conf file is not available, creating it with the provided YAML configuration"

        # Define the Kind cluster configuration inline
        cat <<EOF > "$file_to_search"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  
EOF

        echo "Please enter your desired cluster name:"
        read name

        # Use the inline Kind cluster configuration
        kind create cluster --name $name --config $file_to_search

        echo "Testing if Kind cluster is running or not:"
        kubectl get nodes

        echo "Metrics server configuration started...."

        echo "Applying metrics server components:"
        kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml

        echo "Patching metrics server deployment:"
        kubectl patch -n kube-system deployment metrics-server --type=json \
          -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

        echo "Kind is up and running"
fi

