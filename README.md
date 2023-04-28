# Docker CI/CD Pipeline with Python

# Overview

This repository contains a evolutionary tutorial guide that teaches you how to:

- Create a sample Python application
- Create a new Dockerfile which contains instructions required to build a Python image
- Build an image and run the newly built image as a container
- Set up volumes and networking
- Orchestrate containers using Compose
- Use containers for development
- Configure a CI/CD pipeline for your application using GitHub Actions
- Deploy your application to the cloud (https://docs.docker.com/language/python/deploy/):
    - Docker AWS ECS integration - https://docs.docker.com/cloud/ecs-integration/
        - The Docker ECS Integration enables developers to use native Docker commands in the Docker Compose CLI to run applications in an Amazon EC2 Container Service (ECS) when building cloud-native applications.
    - Kubernetes - https://docs.docker.com/desktop/kubernetes/
        - Docker Desktop includes a standalone Kubernetes server and client, as well as Docker CLI integration that runs on your machine. When you enable Kubernetes, you can test your workloads on Kubernetes.

After completing the Python getting started modules, you should be able to containerize your own Python application based on the examples and instructions provided in this guide.

# Prerequisites

Check Prerequisites and Overview section at https://docs.docker.com/language/python/build-images/ 

# Create a sample Python application

## Create python venv
The sample application (app.py) uses the popular Flask framework. Execute the commands to create venv, install Flask and save the projetct requirements to requirements.txt, which will be used to create the Docker container.
```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install Flask
python3 -m pip freeze > requirements.txt
touch app.py
```

## Test application
```bash
# run "source .venv/bin/activate" if venv not activated
python3 -m flask run
```
Open a new browser and navigate to http://localhost:5000

You should see the message "Hello, Docker!" 

Switch back to the terminal where the server is running and you should see the following requests in the server logs. E.g:

```
127.0.0.1 - - [22/Sep/2020 11:07:41] "GET / HTTP/1.1" 200 -
```

<!-- 
## Create a new Dockerfile which contains instructions required to build a Python image

## Build an image and run the newly built image as a container

## Set up volumes and networking

## Orchestrate containers using Compose

## Use containers for development

## Configure a CI/CD pipeline for your application using GitHub Actions -->


# Useful docker commands

List docker images
```
sudo docker images
```

Remove docker image
```
sudo docker image rm 203f1c887c53 -f
```

List executing containers
```
sudo docker ps
```

Finalize container image by id
```
sudo docker stop 203f1c887c53
```

Generate tag (a copy)
```
sudo docker tag 203f1c887c53 my_tagname
```

List finalized containers with existing metadata
```
sudo docker ps --all
```

Remove metadata
```
docker rm "NAME"
```
- where "NAME" is the correspondig "NAMES" column

Execute python script inside container
```
sudo docker run -it --rm --name my-hello-world-script -v $PWD/helloworld.py:/helloworld.py 203f1c887c53 python /helloworld.py
```

Enter the conatainer with bash
```
sudo docker run -i -t 203f1c887c53 /bin/bash
```

