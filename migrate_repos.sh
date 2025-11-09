#!/bin/bash

#make it executable chmod +x migrate_repos.sh
#run it (./migrate_repos.sh)

# --- Configuration ---
ORIGINAL_MAIN_REPO="https://github.com/consultbibek-beep/mini-gen-reference.git"
ORIGINAL_DIR_MAIN="mini-gen-search" # The name we clone the project into
ORIGINAL_DIR_FRONTEND="frontend-service-reference"
ORIGINAL_DIR_TEXTGEN="textgen-service-reference"

# --- User Input ---

echo "--- 🚀 Git Repository Migration Setup ---"

# 1. New Main Repo
read -p "Enter the NEW main repository name (e.g., mini-gen-search): " NEW_DIR_MAIN
read -p "Enter the NEW main repository URL (HTTPS): " NEW_URL_MAIN
echo ""

# 2. New Frontend Service
read -p "Enter the NEW frontend service name (e.g., frontend-service-search): " NEW_DIR_FRONTEND
read -p "Enter the NEW frontend service URL (HTTPS): " NEW_URL_FRONTEND
echo ""

# 3. New Textgen Service
read -p "Enter the NEW textgen service name (e.g., textgen-service-rag): " NEW_DIR_TEXTGEN
read -p "Enter the NEW textgen service URL (HTTPS): " NEW_URL_TEXTGEN
echo ""

# --- Helper Functions ---

# Function to check if a command failed
check_status() {
    if [ $? -ne 0 ]; then
        echo "🚨 ERROR: $1 failed. Exiting script."
        exit 1
    fi
}

# --- Migration Steps ---

echo "--- 1. Clone Project and Detach Original Connections ---"

# Clone the main repository and all submodules
git clone --recurse-submodules "$ORIGINAL_MAIN_REPO" "$ORIGINAL_DIR_MAIN"
check_status "Cloning $ORIGINAL_MAIN_REPO"

cd "$ORIGINAL_DIR_MAIN"
check_status "Changing directory to $ORIGINAL_DIR_MAIN"

# Remove main repo's original remote and .gitmodules
git remote rm origin
rm -f .gitmodules

echo "--- 2. Detach, Rename, and Clean Up Services ---"

# --- A. Frontend Service ---
echo "Processing Frontend Service..."

# Remove remote from the original submodule directory
if [ -d "$ORIGINAL_DIR_FRONTEND" ]; then
    cd "$ORIGINAL_DIR_FRONTEND"
    git remote rm origin
    cd ..
else
    echo "⚠️ Warning: $ORIGINAL_DIR_FRONTEND directory not found."
fi

# Detach from main repo's index (leaves files on disk)
git rm --cached "$ORIGINAL_DIR_FRONTEND"

# Rename the directory
mv "$ORIGINAL_DIR_FRONTEND" "$NEW_DIR_FRONTEND"
check_status "Renaming $ORIGINAL_DIR_FRONTEND to $NEW_DIR_FRONTEND"

# --- B. Textgen Service ---
echo "Processing Textgen Service..."

# Remove remote from the original submodule directory
if [ -d "$ORIGINAL_DIR_TEXTGEN" ]; then
    cd "$ORIGINAL_DIR_TEXTGEN"
    git remote rm origin
    cd ..
else
    echo "⚠️ Warning: $ORIGINAL_DIR_TEXTGEN directory not found."
fi

# Detach from main repo's index (leaves files on disk)
git rm --cached "$ORIGINAL_DIR_TEXTGEN"

# Rename the directory
mv "$ORIGINAL_DIR_TEXTGEN" "$NEW_DIR_TEXTGEN"
check_status "Renaming $ORIGINAL_DIR_TEXTGEN to $NEW_DIR_TEXTGEN"

# Commit the directory renames and git rm operations in the main repo
git add .
git commit -m "Detached and renamed project directories for migration."

echo "--- 3. Complete Internal Git Cleanup and Re-Init ---"

# Delete all existing Git history (main and services) to prepare for re-initialization
rm -rf .git
rm -rf "$NEW_DIR_FRONTEND/.git"
rm -rf "$NEW_DIR_TEXTGEN/.git"

echo "--- 4. Initialize and Push Service Repositories (Standalone) ---"

# --- A. Frontend Service Re-Init and Push ---
echo "Pushing standalone $NEW_DIR_FRONTEND to $NEW_URL_FRONTEND"
cd "$NEW_DIR_FRONTEND"
git init
git add .
git commit -m "Initial commit for standalone $NEW_DIR_FRONTEND"
git branch -M main
git remote add origin "$NEW_URL_FRONTEND"
git push -u origin main
cd ..
check_status "Pushing $NEW_DIR_FRONTEND"

# --- B. Textgen Service Re-Init and Push ---
echo "Pushing standalone $NEW_DIR_TEXTGEN to $NEW_URL_TEXTGEN"
cd "$NEW_DIR_TEXTGEN"
git init
git add .
git commit -m "Initial commit for standalone $NEW_DIR_TEXTGEN"
git branch -M main
git remote add origin "$NEW_URL_TEXTGEN"
git push -u origin main
cd ..
check_status "Pushing $NEW_DIR_TEXTGEN"

echo "--- 5. Initialize and Push Main Repository ---"

# Create temporary .gitignore to ignore services during main repo init
echo "$NEW_DIR_FRONTEND/" > .gitignore
echo "$NEW_DIR_TEXTGEN/" >> .gitignore

# Initialize the parent repository
git init
git add .
git commit -m "Initialized parent structure; ignoring service directories for submodule re-addition."
git branch -M main
git remote add origin "$NEW_URL_MAIN"
git push -u origin main
check_status "Pushing $NEW_DIR_MAIN parent repository"

# Remove the temporary ignore entries from .gitignore
sed -i '' "/$NEW_DIR_FRONTEND\//d" .gitignore
sed -i '' "/$NEW_DIR_TEXTGEN\//d" .gitignore
git add .gitignore
git commit -m "Restored .gitignore for submodule inclusion."

echo "--- 6. Re-add Submodules and Final Commit ---"

# Add the services back as submodules (this clones them into the now-empty directories)
git submodule add "$NEW_URL_FRONTEND" "$NEW_DIR_FRONTEND"
check_status "Adding $NEW_DIR_FRONTEND as submodule"

git submodule add "$NEW_URL_TEXTGEN" "$NEW_DIR_TEXTGEN"
check_status "Adding $NEW_DIR_TEXTGEN as submodule"

# Commit the final .gitmodules changes
git commit -m "Add $NEW_DIR_FRONTEND and $NEW_DIR_TEXTGEN as submodules with new URLs."
git push
check_status "Final push of main repo with new submodules"

echo ""
echo "✅ SUCCESS! Repository migration is complete."
echo "Your new project is located in the '$ORIGINAL_DIR_MAIN' directory."
echo "Main Repo URL: $NEW_URL_MAIN"
echo "Frontend URL: $NEW_URL_FRONTEND"
echo "Textgen URL: $NEW_URL_TEXTGEN"