https://github.com/consultbibek-beep/mini-gen.git
    https://github.com/consultbibek-beep/frontend-service.git
    https://github.com/consultbibek-beep/textgen-service.git

Repository,Purpose,Assumed Remote URL
Root,Orchestration & Deployment,https://github.com/consultbibek-beep/mini-gen.git
Service 1,Frontend Code,https://github.com/consultbibek-beep/frontend-service.git
Service 2,TextGen Code,https://github.com/consultbibek-beep/textgen-service.git

# Start
docker-compose up --build

http://localhost:8080/

# Stop all running docker
docker stop $(docker ps -q)

# Un-track the service folders in the root repo
git rm -r frontend-service
git rm -r textgen-service
git commit -m "chore: Preparing to add services as submodules"

# Add them back as submodules
git submodule add https://github.com/consultbibek-beep/frontend-service.git frontend-service
git submodule add https://github.com/consultbibek-beep/textgen-service.git textgen-service

# Commit the submodule references (the .gitmodules file is created here)
git commit -m "config: Added frontend and textgen as Git submodules"

# From Docker only to k8s

chmod +x deploy_instructions.sh
./deploy_instructions.sh

mini-gen/
├── frontend-service/
│   ├── app.py
│   ├── Dockerfile
│   ├── pyproject.toml
│   └── requirements.txt  <-- (Needed for Dockerfile)
├── textgen-service/
│   ├── app.py
│   ├── Dockerfile
│   ├── pyproject.toml
│   └── requirements.txt  <-- (Needed for Dockerfile)
├── k8s-manifests/
│   └── k8s-manifests.yaml  <-- (K8s Configs, uses $GROQ_API_KEY placeholder)
├── docker-compose.yml
├── .env                    <-- (Source of truth for GROQ_API_KEY)
└── deploy_instructions.sh  <-- (Automation script, uses envsubst)

# Stop k8s:
kubectl delete deployment frontend-deployment textgen-deployment
kubectl delete service frontend-service textgen
kubectl delete configmap textgen-config
kubectl get all

# CI/CD 
# Updated Project Str

mini-gen/
├── frontend-service/
│   ├── app.py
│   ├── Dockerfile
│   ├── pyproject.toml
│   ├── requirements.txt
│   └── .github/
│       └── workflows/
│           └── docker-publish.yml
│
├── textgen-service/
│   ├── app.py
│   ├── Dockerfile
│   ├── pyproject.toml
│   ├── requirements.txt
│   └── .github/
│       └── workflows/
│           └── docker-publish.yml
│
├── k8s-manifests/
│   └── k8s-manifests.yaml
├── docker-compose.yml
├── .env
└── deploy_instructions.sh

# Updated Project Str

The latest, consolidated project structure for your `mini-gen` setup is provided below. This structure incorporates all the final files and naming conventions confirmed during the troubleshooting process, particularly the separate stop script and the corrected CI/CD workflow names.

## Final Project Structure

```
mini-gen/
├── .env                          <-- Contains DOCKER_HUB and GROQ_API_KEY credentials
├── docker-compose.yml            <-- For local Docker development/testing
├── deploy_instructions.sh        <-- Main script to BUILD and DEPLOY to Kubernetes (using envsubst)
├── deploy_instructions_stop.sh   <-- New script to CLEAN UP all Kubernetes resources

├── k8s-manifests/
│   └── k8s-manifests.yaml        <-- Kubernetes manifests (uses $FRONTEND_TAG, $TEXTGEN_TAG, and $GROQ_API_KEY)

├── frontend-service/             <-- Separate GitHub Repository (Service 1)
│   ├── app.py
│   ├── Dockerfile
│   ├── pyproject.toml
│   ├── requirements.txt
│   └── .github/
│       └── workflows/
│           └── frontend-publish.yml  <-- FINAL CI/CD Workflow (with multi-arch, correct driver, and caching)

└── textgen-service/              <-- Separate GitHub Repository (Service 2)
    ├── app.py
    ├── Dockerfile
    ├── pyproject.toml
    ├── requirements.txt
    └── .github/
        └── workflows/
            └── textgen-publish.yml   <-- FINAL CI/CD Workflow (with multi-arch, correct driver, and caching)
```

# Migration: Refer migrate_fixes.sh

Step-by-Step Summary of Changes

Update k8s-manifests.yaml (Critical Fix)

This step resolves the ErrImagePull error by fixing the image repository names in the Kubernetes Deployment manifests.

Image Name Correction: The missing mini-gen- prefix is added to both Docker image paths (e.g., consultbibek/frontend-service-search becomes consultbibek/mini-gen-frontend-search). This is necessary because your CI/CD workflows are configured to push images with this prefix.

Object Synchronization: Ensures Kubernetes object names, labels, and selectors align with the new schema (e.g., textgen-deployment-rag, frontend-service-search).

Update docker-compose.yml (Local Environment)

This step updates your local development configuration to reflect the new service structure.

Service & Context Renaming: Updates service names (e.g., frontend -> frontend-search) and their corresponding build contexts to the new directory names (e.g., ./frontend-service -> ./frontend-service-search).

Internal Networking: Updates the frontend's TEXTGEN_HOST environment variable to point to the new backend service name (http://textgen-rag:5001).

Update deploy_instructions_stop.sh (Cleanup Script)

This step corrects the project name referenced in the script's output messages for better clarity and consistency.

Message Correction: The project name in the echo messages is updated from mini-gen to mini-gen-search.

Update GitHub Workflow Files (*.yml) (CI/CD Synchronization)

This step ensures full synchronization of image repository names within the CI/CD pipeline, primarily confirming that caching references match the new repository names.

Caching Consistency: Confirms that the cache-from and cache-to references in both frontend-publish.yml and textgen-publish.yml use the correct, full Docker Hub repository name (e.g., consultbibek/mini-gen-frontend-search:buildcache).