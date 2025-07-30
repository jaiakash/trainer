#!/usr/bin/env bash

# Copyright 2024 The Kubeflow Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This shell is used to setup Kind cluster for Kubeflow Trainer e2e tests.

set -o errexit
set -o nounset
set -o pipefail
set -x

# Configure variables.
K8S_VERSION=${K8S_VERSION:-1.32.0}
KIND_NODE_VERSION=kindest/node:v${K8S_VERSION}
NAMESPACE="kubeflow-system"
TIMEOUT="5m"

## Sudo docker to make sure Kind can access GPU
alias kind="sudo kind"
alias nvkind="sudo nvkind"

CLUSTER_NAME=$(kind get clusters | grep nvkind)
nvkind cluster print-gpus

# Delete Kind cluster after validation
echo "Deleting Kind cluster: ${CLUSTER_NAME}"
kind delete cluster --name "${CLUSTER_NAME}"

