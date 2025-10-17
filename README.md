https://github.com/consultbibek-beep/mini-gen.git
    https://github.com/consultbibek-beep/frontend-service.git
    https://github.com/consultbibek-beep/textgen-service.git

Repository,Purpose,Assumed Remote URL
Root,Orchestration & Deployment,https://github.com/consultbibek-beep/mini-gen.git
Service 1,Frontend Code,https://github.com/consultbibek-beep/frontend-service.git
Service 2,TextGen Code,https://github.com/consultbibek-beep/textgen-service.git

#Start
docker-compose up --build

#Stop all running docker
docker stop $(docker ps -q)
