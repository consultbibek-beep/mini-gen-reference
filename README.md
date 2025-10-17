https://github.com/consultbibek-beep/mini-gen.git
    https://github.com/consultbibek-beep/frontend-service.git
    https://github.com/consultbibek-beep/textgen-service.git

Repository,Purpose,Assumed Remote URL
Root,Orchestration & Deployment,https://github.com/consultbibek-beep/mini-gen.git
Service 1,Frontend Code,https://github.com/consultbibek-beep/frontend-service.git
Service 2,TextGen Code,https://github.com/consultbibek-beep/textgen-service.git

#Start
docker-compose up --build

http://localhost:8080/

#Stop all running docker
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

