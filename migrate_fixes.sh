#!/bin/bash
# ==============================================================================
# migrate_fixes.sh (CORRECTED)
# Applies all necessary synchronization updates across configuration files
# for the mini-gen-search project.
# ==============================================================================

# Exit immediately if any command fails
set -e

# Use a temporary file for robust in-place file replacement
TEMP_FILE=$(mktemp)

# Function for robust file replacement using awk
# Note: awk's gsub is used for simple string replacement. Order of operations is critical.
replace_in_file() {
    local SEARCH=$1
    local REPLACE=$2
    local FILE=$3
    echo "  > Updating: $FILE"
    awk -v search_str="$SEARCH" -v replace_str="$REPLACE" '{
        gsub(search_str, replace_str);
        print;
    }' "$FILE" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$FILE"
}

echo "==========================================================="
echo "🛠️ Starting Post-Migration Fixes for mini-gen-search"
echo "==========================================================="

# ==============================================================================
# STEP 1: Update k8s-manifests.yaml (CRITICAL FIX: Image Name & Renaming Order)
# ==============================================================================
echo "--- STEP 1: Updating k8s-manifests.yaml ---"
K8S_FILE="k8s-manifests.yaml" # Assuming k8s-manifests.yaml is in the project root or the script handles the path

# A. CRITICAL FIX: Add 'mini-gen-' prefix to Docker image paths to resolve ErrImagePull.
replace_in_file "consultbibek/frontend-service-search" "consultbibek/mini-gen-frontend-search" "$K8S_FILE"
replace_in_file "consultbibek/textgen-service-rag" "consultbibek/mini-gen-textgen-rag" "$K8S_FILE"

# B. Robust Object Renaming (Old Project Names to New Project Names)
# The order is critical to avoid double-replacement (e.g., changing 'textgen' in 'textgen-deployment' twice).

# 1. Rename full object names first (deployment, configmap)
replace_in_file "name: textgen-deployment" "name: textgen-deployment-rag" "$K8S_FILE"
replace_in_file "name: frontend-deployment" "name: frontend-deployment-search" "$K8S_FILE"
replace_in_file "name: textgen-config" "name: textgen-service-rag-config" "$K8S_FILE"

# 2. Rename partial object names (service, labels)
replace_in_file "name: textgen" "name: textgen-service-rag" "$K8S_FILE"
replace_in_file "name: frontend-service" "name: frontend-service-search" "$K8S_FILE"

# 3. Rename app labels and host references
replace_in_file "app: textgen" "app: textgen-rag" "$K8S_FILE"
replace_in_file "app: frontend" "app: frontend-search" "$K8S_FILE"
replace_in_file "http://textgen:5001" "http://textgen-service-rag:5001" "$K8S_FILE" # Ensure internal link is correct

echo "✅ k8s-manifests.yaml updated with new names and correct image prefixes."

# ==============================================================================
# STEP 2: Update docker-compose.yml (Local Development Synchronization) - Logic is correct
# ==============================================================================
echo "--- STEP 2: Updating docker-compose.yml ---"
DOCKER_COMPOSE_FILE="docker-compose.yml"

# Update Frontend service, context, container name, and dependency
replace_in_file "services:\n  frontend:" "services:\n  frontend-search:" "$DOCKER_COMPOSE_FILE"
replace_in_file "context: ./frontend-service" "context: ./frontend-service-search" "$DOCKER_COMPOSE_FILE"
replace_in_file "container_name: mini-gen-frontend" "container_name: mini-gen-frontend-search" "$DOCKER_COMPOSE_FILE"
replace_in_file "depends_on:\n      - textgen" "depends_on:\n      - textgen-rag" "$DOCKER_COMPOSE_FILE"

# Update TextGen service, context, container name, and environment link
replace_in_file "services:\n  textgen:" "services:\n  textgen-rag:" "$DOCKER_COMPOSE_FILE"
replace_in_file "context: ./textgen-service" "context: ./textgen-service-rag" "$DOCKER_COMPOSE_FILE"
replace_in_file "container_name: mini-gen-textgen" "container_name: mini-gen-textgen-rag" "$DOCKER_COMPOSE_FILE"
replace_in_file "TEXTGEN_HOST=http://textgen:5001" "TEXTGEN_HOST=http://textgen-rag:5001" "$DOCKER_COMPOSE_FILE"

echo "✅ docker-compose.yml updated."

# ==============================================================================
# STEP 3: Update deploy_instructions_stop.sh (Cleanup Script Synchronization) - Logic is correct
# ==============================================================================
echo "--- STEP 3: Updating deploy_instructions_stop.sh ---"
STOP_SCRIPT_FILE="deploy_instructions_stop.sh"

# Fix the project name in the stop script's echo message
replace_in_file "🛑 Stopping and cleaning up Kubernetes resources for mini-gen" "🛑 Stopping and cleaning up Kubernetes resources for mini-gen-search" "$STOP_SCRIPT_FILE"

echo "✅ deploy_instructions_stop.sh updated."

# ==============================================================================
# STEP 4: Update GitHub Workflow Files (REMOVED: Was redundant)
# The workflow files were already pushing the correct image names and do not need
# internal modification for cache consistency.
# ==============================================================================

# ==============================================================================
# FINAL STEP
# ==============================================================================
rm "$TEMP_FILE"
echo "==========================================================="
echo "✅ All post-migration synchronization fixes have been applied."
echo "==========================================================="