#!/bin/bash
set -e

echo "#################################################"
echo "Starting the Jekyll Action"

bundle install
echo "#################################################"
echo "Installion completed"

if [[ -z "${SRC}" ]]; then
  SRC=$(find . -name _config.yml -exec dirname {} \;)
fi

echo "#################################################"
echo "Source for the Jekyll site is set to ${SRC}"

bundle exec jekyll build -s ${SRC} -d build
echo "#################################################"
echo "Jekyll build done"

cd build

# No need to have GitHub Pages to run Jekyll
touch .nojekyll

echo "#################################################"
echo "Now publishing"
if [[ -z "${JEKYLL_PAT}" ]]; then
  echo "using github token"
  TOKEN=${GITHUB_TOKEN}
else 
  echo "using personal access token"
  TOKEN=${JEKYLL_PAT}
fi

echo "figuring out branch from repo URL"
REPO=${PUBLISH_REPO}
if [[ -z "${PUBLISH_REPO}" ]]; then
  REPO=${GITHUB_REPOSITORY}
fi
echo "publishing to repo ${REPO}"
if [[ ${REPO} =~ \.github\.io$ ]]; then
  remote_branch="master"
else
  remote_branch="gh-pages"
fi
echo "using branch ${remote_branch}"

remote_repo="https://${TOKEN}@github.com/${REPO}.git"
git init
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git add .
git commit -m 'jekyll build from Action'
git push --force $remote_repo master:$remote_branch
rm -fr .git