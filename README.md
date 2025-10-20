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

