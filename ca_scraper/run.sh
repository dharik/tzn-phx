#!/bin/bash

rm ./*.png
docker build -t ca-scrape .
docker run --shm-size 1G --rm --cap-add=SYS_ADMIN -v `pwd`:/app/ ca-scrape node index.js

