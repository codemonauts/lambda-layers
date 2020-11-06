#! /usr/bin/env bash
set -e

REGION=$1

echo "# Build for Python 3.7 (Lambda@Edge)"
docker run -v "$PWD":/var/task "lambci/lambda:build-python3.7" /bin/sh -c "pip install --upgrade -r requirements.txt -t python/lib/python3.7/site-packages/; exit"

echo "# Build for Python 3.8"
docker run -v "$PWD":/var/task "lambci/lambda:build-python3.8" /bin/sh -c "pip install --upgrade -r requirements.txt -t python/lib/python3.8/site-packages/; exit"

echo "# Creating zip"
zip -r requests.zip python > /dev/null

echo "# Uploading"
if [ -z $REGION ]; then
  echo "No region was given. Defaulting to 'us-east-1'"
  REGION="us-east-1"
fi
aws lambda publish-layer-version --region $REGION --layer-name requests --description "requests" --zip-file fileb://requests.zip --compatible-runtimes "python3.7" "python3.8"

echo "# Cleaning up"
rm -rf requests.zip
