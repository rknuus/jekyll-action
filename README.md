# yet-another-jekyll-action
A GitHub Action to build and publish Jekyll sites to GitHub Pages. Forked from [helaili](https://github.com/helaili/jekyll-action) and simplified.

Out-of-the-box Jekyll with GitHub Pages allows you to leverage a limited, white-listed, set of gems. Complex sites using additional gems (AsciiDoc for intstance) require a continuous integration build in order to pre-process the site.

## Usage

### Create a Jekyll site
Create a new Jekyll site from scratch with `jekyll new sample-site`. See [the Jekyll website](https://jekyllrb.com/) for more information.

Note: If you plan to use asciidoc/asciidoctor either you have to convert md files to adoc or you could start off by forking [Jekyll AsciiDoc Quickstart](https://github.com/asciidoctor/jekyll-asciidoc-quickstart). In this case you can remove the files `.travis.yml` and `Rakefile`.

### Create a `Gemfile`
To leverage specific gems specify them in a `Gemfile`. The following example uses the [github-pages](https://github.com/github/pages-gem) gem to base Jekyll on the GitHub Pages approach and adds the [Jekyll AsciiDoc plugin](https://github.com/asciidoctor/jekyll-asciidoc)

```Ruby
source "https://rubygems.org"

gem "bundler"

group :jekyll_plugins do
  gem "github-pages", '~> 202'
  gem 'jekyll-asciidoc', '~> 2.1.1'
end
```

### Configure your Jekyll site
Edit the configuration file of your Jekyll site (`_config.yml`) to configure these plugins. The configuration for a blog site could look as follows:

```yaml
title: <your title>
description: >-
  <your description>
author: <your name>
email: <your email>
url: <the site's URL>
github_username: <your github user name>
theme: minima
plugins:
  - jekyll-feed
  - jekyll-asciidoc
asciidoc: {}
asciidoctor:
  base_dir: :docdir
  safe: unsafe
  attributes:
    - imagesdir=/images/post-images/
    - icons=font
    - source-highlighter=coderay
    - coderay-css=style
    - figure-caption!
permalink: /blog/:year/:month/:day/:title

exclude:
  - .jekyll-cache/
  - Gemfile
  - Gemfile.lock
  - README.md
```

### Configure CI
Create a file `.github/workflows/main.yml` in your project with content:
```
name: CI

on:
  push:
      branches:
        - master

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2
        with:
          ref: master
      - name: Jekyll Action
        uses: rknuus/yet-another-jekyll-action@master
        env:
          JEKYLL_PAT: ${{ secrets.JEKYLL_PAT }}
          PUBLISH_REPO: <account>/<account>.github.io
```

By default the publishing script automatically determines the Jekyll source directory (which contains file `_config.yml`). To customize the path you can pass an `env` variable called `SRC`.

Unless customized by passing `env` variable `BUILD_DIR` the output directory of Jekyll is set to `_site`.

The Jekyll output is published to the same repository containing the sources. To customize the repository to publish to pass an `env` variable `PUBLISH_REPO`.

Unless customized by passing `env` variable `PUBLISH_BRANCH` the plublication branch is set to "master" for repositories https://&lt;account&gt;.github.io or to "gh-master" for all other repositories.

### Configure GitHub project
First create a new project on GitHub and follow the steps explained in the empty GitHub repository to link your local repository to the remote one.

In [Settings/Developer settings/Personal access tokens](https://github.com/settings/tokens) create a new token with access to all `repo` elements. Copy the token for later use.

In your GitHub project's settings/Secrets press "Add a new secret", enter "JEKYLL_PAT" as name and the token as value. Secrets are explained in the [GitHub help](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets).

In your GitHub project's settings/Options scroll down to section "GitHub Pages" and select "master branch" as Source.

On every push to branch master go to tab "Actions" on your project site and click on the triggered CI build to track publishing progress.

## Known limitations
In the setup described above the site will be published twice, a custom one available under https://&lt;account&gt;.github.io and the standard one (with limited Jekyll plugin support) to https://&lt;account&gt;.github.io/&lt;project&gt;.