#!/bin/bash
scp -r /mounted ubuntu@194.47.177.127:
ssh ubuntu@194.47.177.127 /bin/bash << HERE
  scp -r mounted ubuntu@172.16.0.8:
HERE