#!/bin/bash
set -e

die() { echo "$*" 1>&2 ; exit 1; }

echo "#################################################"
echo "Evaluating & verifying paramters..."
[[ -z "${JEKYLL_PAT}" ]] && die "No environment variable JEKYLL_PAT defined containing a personal access token"

[[ -z "${SRC}" ]] && SRC=$(find . -name _config.yml -exec dirname {} \;)
[[ -z "${SRC}" ]] && die "Error: could not locate source directory containing file _config.yml"
echo "Source for the Jekyll site is set to ${SRC}"

[[ -z "${BUILD_DIR}" ]] && BUILD_DIR=_site
echo "Output directory is set to ${BUILD_DIR}"

REPO_NAME=${PUBLISH_REPO}
[[ -z "${REPO_NAME}" ]] && REPO_NAME=${GITHUB_REPOSITORY}
echo "Remote repository name is set to ${REPO_NAME}"

REMOTE_BRANCH=${PUBLISH_BRANCH}
if [[ -z "${REMOTE_BRANCH}" ]]; then
    REMOTE_BRANCH="master"
    [[ ${REPO_NAME} =~ \.github\.io$ ]] || REMOTE_BRANCH="gh-pages"
fi
echo "Remote repository branch is set to ${REMOTE_BRANCH}"

REMOTE_REPO="https://${JEKYLL_PAT}@github.com/${REPO_NAME}.git"
echo "Full remote repository URL is not printed because of the token"

echo "#################################################"
echo "Installing..."
bundle install

echo "#################################################"
echo "Building..."
bundle exec jekyll build -s ${SRC} -d ${BUILD_DIR}

echo "#################################################"
echo "Publishing..."
cd ${BUILD_DIR}
touch .nojekyll  # No need to have GitHub Pages to run Jekyll
git init
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git add .
git commit -m 'jekyll build from action'
git push --force ${REMOTE_REPO} master:${REMOTE_BRANCH}
rm -fr .git

echo "#################################################"
echo "Successfully published your site."
