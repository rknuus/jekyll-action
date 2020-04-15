FROM ruby:2-slim

LABEL version="1.2.0"
LABEL repository="https://github.com/rknuus/yet-another-jekyll-action"
LABEL homepage="https://github.com/rknuus/yet-another-jekyll-action"
LABEL maintainer="rknuus@gmail.com"

LABEL "com.github.actions.name"="Yet Another Jekyll Action"
LABEL "com.github.actions.description"="A GitHub Action to build and publish Jekyll sites to GitHub Pages"
LABEL "com.github.actions.icon"="book"
LABEL "com.github.actions.color"="blue"
COPY LICENSE README.md

RUN apt update && \
    apt install --no-install-recommends -y \
        bats \
        build-essential \
        ca-certificates \
        curl \
        git \
        libffi6 \
        make \
        python \
        shellcheck \
    && bundle config --global silence_root_warning 1

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
