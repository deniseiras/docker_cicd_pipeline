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