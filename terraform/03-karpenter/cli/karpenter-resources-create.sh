#!/bin/bash
set -euo pipefail

RENDERED_NODE_CLASS="$(mktemp)"
trap 'rm -f "$RENDERED_NODE_CLASS"' EXIT

function enableKubernetesClusterConnection(){
    aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"
}

function renderKarpenterNodeClass(){
   # Substitute into a temp file, not in-place: `sed -i` needs a backup-suffix
   # arg on BSD/macOS sed but not on GNU sed, so in-place edits silently no-op
   # (or error) depending on platform. This form works identically everywhere
   # and leaves the checked-in template untouched.
   sed \
     -e "s|\${CLUSTER_NAME}|$CLUSTER_NAME|g" \
     -e "s|\${KARPENTER_NODE_ROLE}|$KARPENTER_NODE_ROLE|g" \
     ./resources/karpenter-node-class.yml > "$RENDERED_NODE_CLASS"
}

function CreateKarpenterResources(){
    kubectl apply -f "$RENDERED_NODE_CLASS"
    kubectl apply -f ./resources/karpenter-node-pool.yml
}

enableKubernetesClusterConnection
renderKarpenterNodeClass
CreateKarpenterResources
