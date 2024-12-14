#!/bin/bash

# Create working directory
mkdir -p mssql-lambda-build
cd mssql-lambda-build

# Create a directory structure for the layer
mkdir -p python/lib/python3.10/site-packages

# Create a requirements.txt file
cat > requirements.txt << EOL
pyodbc==4.0.39
EOL

# Create a Dockerfile for building the layer
cat > Dockerfile << EOL
FROM public.ecr.aws/lambda/python:3.10

# Install system dependencies
RUN yum update -y && \
    yum install -y unixODBC unixODBC-devel gcc gcc-c++ python3-devel curl make

# Install Microsoft ODBC Driver for SQL Server
RUN curl https://packages.microsoft.com/config/rhel/8/prod.repo > /etc/yum.repos.d/mssql-release.repo && \
    ACCEPT_EULA=Y yum install -y msodbcsql18

WORKDIR /layer

# Copy requirements
COPY requirements.txt .

# Install Python packages
RUN pip install -r requirements.txt -t python/lib/python3.10/site-packages/

# Copy the ODBC drivers and their dependencies
RUN mkdir -p python/lib && \
    cp -r /opt/microsoft python/ && \
    cp -r /usr/lib64/libmsodbcsql* python/lib/ && \
    cp -r /usr/lib64/libodbccr* python/lib/ && \
    cp -r /usr/lib64/libodbcinst* python/lib/
EOL

# Build the Docker image
docker build -t mssql-layer .

# Create a container and copy the layer contents
docker create --name temp_container mssql-layer bash
docker cp temp_container:/layer/python .
docker rm temp_container

# Create the ZIP file for the Lambda layer
zip -r ../mssql-lambda-layer.zip python/

# Clean up
cd ..
rm -rf mssql-lambda-build