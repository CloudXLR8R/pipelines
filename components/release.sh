#!/bin/bash
#
# Copyright 2018-2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script automated the process to release the component images.
# To run it, find a good release candidate commit SHA from ml-pipeline-test project,
# and provide a full github COMMIT SHA to the script. E.g.
# ./release.sh 2118baf752d3d30a8e43141165e13573b20d85b8
# The script copies the images from test to prod, and update the local code.
# You can then send a PR using your local branch.

set -xe

COMMIT_SHA=$1
REPO=kubeflow/pipelines
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"

if [ -z "$COMMIT_SHA" ]; then
  echo "Usage: release.sh <commit-SHA>" >&2
  exit 1
fi

# Checking out the repo
clone_dir=$(mktemp -d)
git clone "git@github.com:${REPO}.git" "$clone_dir"
cd "$clone_dir"
branch="release-$COMMIT_SHA"
# Creating the release branch from the specified commit
release_head=$COMMIT_SHA
git checkout "$release_head" -b "$branch"

source "$DIR/update-for-release.sh"
update_for_release $COMMIT_SHA

# Pushing the changes upstream
read -p "Do you want to push the new branch to upstream to create a PR? [y|n]"
if [ "$REPLY" != "y" ]; then
   exit
fi
git push --set-upstream origin "$branch"

sensible-browser "https://github.com/${REPO}/compare/master...$branch"
