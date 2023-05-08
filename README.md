# Docker CI/CD Pipeline with Python

# Overview

This repository contains a evolutionary tutorial that teaches you how to:

- Easily install docker
- Create a sample Python application
- Create a new Dockerfile which contains instructions required to build a Python image
- Build an image and run the newly built image as a container
- Set up volumes and networking
- Orchestrate containers using Compose
- Use containers for development
- Configure a CI/CD pipeline for your application using GitHub Actions, deploying in Docker Hub.
- Deploy your application to the cloud.


This tutotial implements the tutorial at https://docs.docker.com/language/python/ , distributing the files with some improvements and facilities.

# Prerequisites

Check Prerequisites and Overview section at https://docs.docker.com/language/python/build-images/ . 

After that you may follow the steps here and try to install docker using the convenience script

## Install docker using the convenience script

Docker provides a convenience script at https://get.docker.com/ to install Docker into development environments non-interactively. You can find it in the [docker-install repository on GitHub](https://github.com/docker/docker-install).


This example downloads the script from https://get.docker.com/ and runs it to install the latest stable release of Docker on Linux. You can run the script with the --dry-run option to learn what steps the script will run when invoked:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh  #  --dry-run
```

# Create a sample Python application

## Fork this repository

You you need to fork this repository (instead of just using) because you need to configure GithHub actions ahead.
```bash
git clone https://github.com/deniseiras/docker_cicd_pipeline.git
```

## Create python 3.8 venv
The sample application (app.py) uses the popular Flask framework. Execute the commands to create venv, install Flask and save the projetct requirements to requirements.txt, which will be used to create the Docker container.

**Ensure using python 3.8 for this tutorial, otherwise your Docker could not work even if the app works**
```bash
python3.8 -m venv .venv
source .venv/bin/activate
python3 -m pip install Flask
python3 -m pip freeze > requirements.txt
```

## Test application

The app name must be app.py. So, copy app_hello_docker.py to app.py first.

```bash
# run "source .venv/bin/activate" if venv not activated
cp app_hello_docker.py app.py
python3 -m flask run
```
Open a new browser and navigate to http://localhost:5000

You should see the message "Hello, Docker!" 

Switch back to the terminal where the server is running and you should see the following requests in the server logs. E.g:

```
127.0.0.1 - - [22/Sep/2020 11:07:41] "GET / HTTP/1.1" 200 -
```
Finalize the app by presssing CTRL+C on terminal.

## Create a new Dockerfile which contains instructions required to build a Python image

Now that the application is running, you can create a Dockerfile from it. Dockerfile is a template to create your docker image. Check already created Dockerfile in this repo:

Dockerfile

```Dockerfile
# syntax=docker/dockerfile:1

# Docker images can inherit from other images. You can use the official Python image that has all the tools and packages needed to run a Python application.
FROM python:3.8-slim-buster

# This instructs Docker to use this path as the default location for all subsequent commands. This means you can use relative file paths based on the working directory instead of full file paths.
WORKDIR /app

# The COPY command takes two parameters. The first parameter tells Docker what file(s) you would like to copy into the image. The second parameter tells Docker where to copy that file(s) to. For this example, copy the requirements.txt file into the working directory /app.
COPY requirements.txt requirements.txt

RUN pip3 install -r requirements.txt

# This COPY command takes all the files located in the current directory and copies them into the image.
COPY . .

# Now, tell Docker what command to run when the image is executed inside a container using the CMD command. Note that you need to make the application externally visible (i.e. from outside the container) by specifying --host=0.0.0.0.
CMD ["python3", "-m" , "flask", "run", "--host=0.0.0.0"]
```

## Build an image and run the newly built image as a container

Now that you’ve created the Dockerfile, let’s build the image. To do this, use the docker build command. The docker build command builds Docker images from a Dockerfile and a “context”. A build’s context is the set of files located in the specified PATH or URL. The Docker build process can access any of the files located in this context.

The build command optionally takes a --tag flag. The tag sets the name of the image and an optional tag in the format name:tag. Leave off the optional tag for now to help simplify things. If you don’t pass a tag, Docker uses “latest” as its default tag.

Build the Docker image.

```bash
sudo docker build --tag python-docker .
```
```
[+] Building 2.7s (10/10) FINISHED
 => [internal] load build definition from Dockerfile
 => => transferring dockerfile: 203B
 => [internal] load .dockerignore
 => => transferring context: 2B
 => [internal] load metadata for docker.io/library/python:3.8-slim-buster
 => [1/6] FROM docker.io/library/python:3.8-slim-buster
 => [internal] load build context
 => => transferring context: 953B
 => CACHED [2/6] WORKDIR /app
 => [3/6] COPY requirements.txt requirements.txt
 => [4/6] RUN pip3 install -r requirements.txt
 => [5/6] COPY . .
 => [6/6] CMD ["python3", "-m", "flask", "run", "--host=0.0.0.0"]
 => exporting to image
 => => exporting layers
 => => writing image sha256:8cae92a8fbd6d091ce687b71b31252056944b09760438905b726625831564c4c
 => => naming to docker.io/library/python-docker
```

To see a list of images you have on your local machine, you have two options. One is to use the Docker CLI and the other is to use Docker Desktop. As you are working in the terminal already, take a look at listing images using the CLI.

To list images, run the command:
```
sudo docker images
```
```
REPOSITORY          TAG               IMAGE ID       CREATED             SIZE
python-docker       latest            7885d7bf3a89   35 minutes ago      148MB
```

## Run image as container

A container is a normal operating system process except that this process is isolated in that it has its own file system, its own networking, and its own isolated process tree separate from the host.

To run an image inside of a container, we use the `docker run` command. The docker run command requires one parameter which is the name of the image. 
```
sudo docker run python-docker
```
```
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://172.17.0.2:5000
Press CTRL+C to quit
```
To acess the app, ctrl+click at the external link generated by the docker run command, i.e. http://172.17.0.2:5000 .

After, finalize the app by presssing CTRL+C on terminal.

## Set up volumes and networking

### Run a database in a container
First, we’ll take a look at running a database in a container and how we use volumes and networking to persist our data and allow our application to talk with the database. Then we’ll pull everything together into a Compose file which allows us to setup and run a local development environment with one command.

Instead of downloading MySQL, installing, configuring, and then running the MySQL database as a service, we can use the Docker Official Image for MySQL and run it in a container.

Before we run MySQL in a container, we’ll create a couple of volumes that Docker can manage to store our persistent data and configuration. Let’s use the managed volumes feature that Docker provides instead of using bind mounts. You can read all about Using volumes in docker documentation.

Let’s create our volumes now. We’ll create one for the data and one for configuration of MySQL.
```
sudo docker volume create mysql
sudo docker volume create mysql_config
```
Now we’ll create a network that our application and database will use to talk to each other. The network is called a user-defined bridge network and gives us a nice DNS lookup service which we can use when creating our connection string.

```
sudo docker network create mysqlnet
```

Now we can run MySQL in a container and attach to the volumes and network we created above. Docker pulls the image from Hub and runs it for you locally. In the following command, option -v is for starting the container with volumes. For more information, see Docker volumes.

```
sudo docker run --rm -d -v mysql:/var/lib/mysql \
  -v mysql_config:/etc/mysql -p 3306:3306 \
  --network mysqlnet \
  --name mysqldb \
  -e MYSQL_ROOT_PASSWORD=p@ssw0rd1 \
  mysql
```
Now, let’s make sure that our MySQL database is running and that we can connect to it. Connect to the running MySQL database inside the container using the following command and enter “p@ssw0rd1” when prompted for the password:

```
sudo docker exec -ti mysqldb mysql -u root -p
```

## Connect the application to the database

Okay, now that we have a running MySQL, let’s use the app_mysql.py to use MySQL as a datastore. Let’s also add some routes to our server. One for fetching records and one for creating our database and table.

First, copy app_mysql.py to app.py first. Then add the mysql-connector-python module to our application using pip. Ensure you are in venv!

```
cp app_mysql.py app.py
pip3 install mysql-connector-python
pip3 freeze | grep mysql-connector-python >> requirements.txt
```

Now we can build our "dev" image.
```
sudo docker build --tag python-docker-dev .
```

**If you have any containers running from the previous sections using the name rest-server or port 8000, stop them now. (`sudo docker ps; sudo docker stop "containerId"`)**

Now, let’s add the container to the database network and then run our container. This allows us to access the database by its container name.

```
sudo docker run \
  --rm -d \
  --network mysqlnet \
  --name rest-server \
  -p 8000:5000 \
  python-docker-dev
```

Let’s test that our application is connected to the database and is able to add a note.
```bash
curl http://localhost:8000/initdb
```
You should receive the message: `Database Initilized!`

```bash
curl http://localhost:8000/widgets
```

You should receive and empty JSON back from our service: `[]`

## Orchestrate containers using Compose

Now we’ll create a Compose file to start our python-docker and the MySQL database using a single command.

The docker-compose.dev.yml Compose file is super convenient as we do not have to type all the parameters to pass to the docker run command. 

We expose port 8000 so that we can reach the dev web server inside the container. We also map our local source code into the running container to make changes in our text editor and have those changes picked up in the container.

Another really cool feature of using a Compose file is that we have service resolution set up to use the service names. Therefore, we are now able to use “mysqldb” in our connection string. The reason we use “mysqldb” is because that is what we’ve named our MySQL service as in the Compose file.

Note that we did not specify a network for those 2 services. When we use docker-compose it automatically creates a network and connect the services to it. For more information see Networking in Compose

**If you have any containers running from the previous sections, stop them now (`sudo docker ps; sudo docker stop "containerId"`).**

Now, to start our application and to confirm that it is running properly, run the following command:
```bash
sudo docker compose -f docker-compose.dev.yml up --build
```

We pass the --build flag so Docker will compile our image and then start the containers.

Now let’s test our API endpoint. Open a new terminal then make a GET request to the server using the curl commands:

```bash
 curl http://localhost:8000/initdb
 curl http://localhost:8000/widgets
```
You should receive the following responses:
```bash
Database Initilized!
[]
```


[]
This is because our database is empty.

## Configure a CI/CD pipeline for your application using GitHub Actions 

This tutorial walks you through the process of setting up and using Docker GitHub Actions for building Docker images, and pushing images to Docker Hub. You will complete the following steps:

1. Step 1: Configure the Docker Hub secret
2. Step 2: Define the GitHub Actions workflow.
3. Step 3: Run the workflow.

To follow this tutorial, you need to [Create your Docker ID](https://hub.docker.com/) (if you not have any) and a GitHub account. 

### Step 1: Configure the Docker Hub secrets.

1. Open the repository Settings, and go to Secrets > Actions.
2. Create a new secret named `DOCKERHUB_USERNAME` and your Docker ID as value.
3. Create a new [Personal Access Token (PAT)](https://docs.docker.com/docker-hub/access-tokens/#create-an-access-token) for Docker Hub. You can name this token `clockboxci`.
4. Add the PAT as a second secret in your GitHub repository, with the name `DOCKERHUB_TOKEN`.

### Step 2: Define the GitHub Actions workflow

Set up your GitHub Actions workflow for building and pushing the image to Docker Hub.

The workflow is under your `.github/workflows/main.yml`.

the basic definitios are:
- `name`: the name of this workflow.
- `on.push.branches`: specifies that this workflow should run on every push event for the branches in the list.
- `jobs`: creates a job ID (build) and declares the type of machine that the job should run on.

The job defined on YAML snippet contains a sequence of steps that:

- Checks out the repository on the build machine.
- Signs in to Docker Hub, using the [Docker Login](https://github.com/marketplace/actions/docker-login) action and your Docker Hub credentials.
- Creates a BuildKit builder instance using the [Docker Setup Buildx action](https://github.com/marketplace/actions/docker-setup-buildx).
- Builds the container image and pushes it to the Docker Hub repository, using [Build and push Docker images](https://github.com/marketplace/actions/build-and-push-docker-images).
    - The with key lists a number of input parameters that configures the step:
      - `context`: the build context.
      - `file`: filepath to the Dockerfile.
      - `push`: tells the action to upload the image to a registry after building it.
      - `tags`: tags that specify where to push the image.

For more information about the YAML syntax used here, see [Workflow syntax for GitHub Actions](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

### Step 3: Run the workflow

1. Making a change in any file, committing and pushing to the main branch will trigger the GitHub Actions at `.github/workflows` directory. 
    - A good idea is to push your requirements.txt file, which could be different than the initial version from the repository

2. Go to the Actions tab. It displays the workflow. Selecting the workflow shows you the breakdown of all the steps, like the image below:
![image](https://user-images.githubusercontent.com/6113640/236876664-f681058f-7320-4f6f-93f4-5eb56a933462.png)


3. When the workflow is complete, go to your [repositories on Docker Hub](https://hub.docker.com/repositories).

If you see the new repository in that list, it means the GitHub Actions successfully pushed the image to Docker Hub!

<p align="center">
  <img src="https://user-images.githubusercontent.com/6113640/236882371-df56a8a2-5990-4a3d-838c-d2226e6280af.png" alt="Alt text">
   
You finished the tutorial! 👏 👏 👏
</p>

Cheers! 🍻


# Next steps: Deploy your application to the cloud

Now that we have configured a CI/CD pipeline, let’s look at how we can deploy the application. Docker supports deploying containers on Azure ACI and AWS ECS. You can also deploy your application to Kubernetes if you have enabled Kubernetes in Docker Desktop.

For advancing in deploy, you can use the [original tutorials from docker](https://docs.docker.com/language/python/deploy/).

# Useful docker commands

List docker images
```
sudo docker images
```

Remove docker image
```
sudo docker image rm 7885d7bf3a89 -f
```

List executing containers
```
sudo docker ps
```

Finalize container image by id
```
sudo docker stop 7885d7bf3a89
```

Generate tag (a copy)
```
sudo docker tag 7885d7bf3a89 my_tagname
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
sudo docker run -it --rm --name my-hello-world-script -v $PWD/helloworld.py:/helloworld.py 7885d7bf3a89 python /helloworld.py
```

Enter the conatainer with bash
```
sudo docker run -i -t 7885d7bf3a89 /bin/bash
```

