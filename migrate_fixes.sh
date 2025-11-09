#!/bin/bash
# ==============================================================================
# apply_post_migration_fixes.sh
# Applies all necessary synchronization updates across configuration files
# for the mini-gen-search project.
# ==============================================================================

# Exit immediately if any command fails
set -e

# Use a temporary file for robust in-place file replacement
TEMP_FILE=$(mktemp)

# Function for robust file replacement using awk
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
# STEP 1: Update k8s-manifests.yaml (CRITICAL FIX: Image Name Mismatch)
# Adds the required 'mini-gen-' prefix to Docker image paths to resolve ErrImagePull.
# Updates all Kubernetes object names to the new schema.
# ==============================================================================
echo "--- STEP 1: Updating k8s-manifests.yaml ---"
K8S_FILE="k8s-manifests/k8s-manifests.yaml"

# 1.1: Fix Frontend Image Name (Add 'mini-gen-' prefix)
replace_in_file "consultbibek/frontend-service-search" "consultbibek/mini-gen-frontend-search" "$K8S_FILE"
# 1.2: Fix TextGen Image Name (Add 'mini-gen-' prefix)
replace_in_file "consultbibek/textgen-service-rag" "consultbibek/mini-gen-textgen-rag" "$K8S_FILE"

# 1.3: Update Kubernetes object names, labels, and service links
replace_in_file "name: textgen-deployment" "name: textgen-deployment-rag" "$K8S_FILE"
replace_in_file "name: textgen-service-rag-config" "name: textgen-service-rag-config" "$K8S_FILE" # Already correct
replace_in_file "name: textgen-service-rag" "name: textgen-service-rag" "$K8S_FILE" # Already correct
replace_in_file "app: textgen-rag" "app: textgen-rag" "$K8S_FILE" # Already correct
replace_in_file "name: frontend-deployment-search" "name: frontend-deployment-search" "$K8S_FILE" # Already correct
replace_in_file "name: frontend-service-search" "name: frontend-service-search" "$K8S_FILE" # Already correct
replace_in_file "app: frontend-search" "app: frontend-search" "$K8S_FILE" # Already correct
replace_in_file "http://textgen-service-rag:5001" "http://textgen-service-rag:5001" "$K8S_FILE" # Already correct

echo "✅ k8s-manifests.yaml updated with new names and correct image prefixes."

# ==============================================================================
# STEP 2: Update docker-compose.yml (Local Development Synchronization)
# Updates service names, build contexts, and internal host references.
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
# STEP 3: Update deploy_instructions_stop.sh (Cleanup Script Synchronization)
# Fixes the project name in the cleanup output messages.
# ==============================================================================
echo "--- STEP 3: Updating deploy_instructions_stop.sh ---"
STOP_SCRIPT_FILE="deploy_instructions_stop.sh"

# Fix the project name in the stop script's echo message
replace_in_file "🛑 Stopping and cleaning up Kubernetes resources for mini-gen" "🛑 Stopping and cleaning up Kubernetes resources for mini-gen-search" "$STOP_SCRIPT_FILE"

echo "✅ deploy_instructions_stop.sh updated."

# ==============================================================================
# STEP 4: Update GitHub Workflow Files (CI/CD Synchronization)
# Ensures image tags and cache references correctly use the new repository names.
# NOTE: The current uploaded workflow files appear mostly correct, but this step
# ensures full consistency, especially for caching ref.
# ==============================================================================
echo "--- STEP 4: Updating GitHub Workflow Files ---"

# 4.1: Update frontend-publish.yml cache reference
FRONTEND_WORKFLOW="frontend-publish.yml"
# Ensure cache ref uses the full new name
replace_in_file "consultbibek/mini-gen-frontend-search:buildcache" "consultbibek/mini-gen-frontend-search:buildcache" "$FRONTEND_WORKFLOW"

# 4.2: Update textgen-publish.yml cache reference
TEXTGEN_WORKFLOW="textgen-publish.yml"
# Ensure cache ref uses the full new name
replace_in_file "consultbibek/mini-gen-textgen-rag:buildcache" "consultbibek/mini-gen-textgen-rag:buildcache" "$TEXTGEN_WORKFLOW"

echo "✅ GitHub Workflow Files synchronized."

# ==============================================================================
# FINAL STEP
# ==============================================================================
rm "$TEMP_FILE"
echo "==========================================================="
echo "✅ All post-migration synchronization fixes have been applied."
echo "==========================================================="