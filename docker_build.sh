#!/bin/bash

# --- Configuration ---
IMAGE_NAME="ubuntu-ansible-node"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

echo "--- Starting Docker image build: ${FULL_IMAGE_NAME} ---"
echo ""

# The docker build command:
# -t: Tags the resulting image with the specified name and tag.
# .: Specifies the build context, which is the current directory (where the Dockerfile is located).
docker build -t "${FULL_IMAGE_NAME}" .

# Check the exit status of the docker build command
if [ $? -eq 0 ]; then
    echo ""
    echo "--- Build successful! ---"
    echo "Image ${FULL_IMAGE_NAME} is now available locally."
    echo "Run 'docker images' to verify."
else
    echo ""
    echo "--- Build failed! ---"
    echo "Please check the Dockerfile for errors."
fi