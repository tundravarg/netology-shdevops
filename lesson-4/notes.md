# Notes



## How to login to dockerhub.com


```shell
gpg --generate-key
pass init 123...

# https://hub.docker.com/settings/security?generateToken=true
docker login -u tumanser
```


## Build and publish Docker image


```shell
docker pull nginx:1.21.1
docker image ls

docker build .
docker build -t tumanser/custom-nginx:1.0.0 .

docker image rm -f 35db2216da65

docker push tumanser/custom-nginx:1.0.0
```


## Run and debug Docker image


```shell
docker run -d -p 81:80 tumanser/custom-nginx:1.0.0
docker ps
curl http://localhost:81
docker exec -it brave_benz bash
docker kill suspicious_dubinsky
```



