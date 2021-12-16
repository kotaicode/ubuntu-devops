FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  apache2-utils \
  apt-transport-https \
  build-essential \
  ca-certificates \
  curl \
  dnsutils \
  git \
  gnupg \
  jq \
  libffi-dev \
  libssl-dev \
  lsb-release \
  make \
  mysql-client \
  nano \
  postgresql-client \
  python-all-dev \
  python3-pip \
  python-setuptools \
  python3.6 \
  redis-tools \
  ruby-full \
  silversearcher-ag \
  ssh-client \
  tmux \
  unzip \
  vim \
  wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

#magic wormhole to send/receive secrets
RUN pip install magic-wormhole

# yamllint
RUN pip install yamllint

RUN wget https://github.com/mikefarah/yq/releases/download/v4.16.1/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install

# Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# GCloud SDK
ENV GCLOUD_SDK_VERSION="256.0.0"
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar -xzvf google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    /google-cloud-sdk/install.sh -q && \
    ln -s /google-cloud-sdk/bin/* /usr/local/bin && \
    gcloud --version && \
    rm google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz

# install go
RUN wget https://golang.org/dl/go1.17.3.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.17.3.linux-amd64.tar.gz
ENV GOROOT=/usr/local/go
ENV PATH=$PATH:/usr/local/go/bin

# RABBITMQ tooling
RUN wget https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/v3.7.15/bin/rabbitmqadmin -O ~/rabbitmqadmin
RUN chmod +x ~/rabbitmqadmin
RUN mv ~/rabbitmqadmin /usr/bin/
#install rabtap
RUN GO111MODULE=on go get github.com/jandelgado/rabtap/cmd/rabtap

# install terraform
RUN wget https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_linux_amd64.zip
RUN unzip terraform_0.12.19_linux_amd64.zip
RUN mv terraform /usr/bin/

# Vim plugins
# pathogen
RUN mkdir -p $HOME/.vim/autoload $HOME/.vim/bundle && \
  curl -LSso $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
COPY vimrc /root/.vimrc
# Sensible
RUN git clone https://github.com/tpope/vim-sensible.git $HOME/.vim/bundle/vim-sensible && \
# Dockerfile syntax & snippet plugin
    git clone https://github.com/ekalinin/Dockerfile.vim.git $HOME/.vim/bundle/Dockerfile && \
# Vim airline
    git clone https://github.com/bling/vim-airline $HOME/.vim/bundle/vim-airline && \
# CtrlP
    git clone https://github.com/kien/ctrlp.vim.git $HOME/.vim/bundle/ctrlp.vim && \
# vim-go
    git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go

# mongo client
#RUN wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add -
#RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list
#RUN apt-get update && apt-get install -y mongodb-mongosh

# nodejs & yarn
RUN curl -sL https://deb.nodesource.com/setup_16.x  | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get -y install nodejs yarn \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# jsonlint
RUN npm install jsonlint -g


#mssql-cli

#RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
#    && curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/20.04/prod.list
#
#RUN apt-get update && apt-get -y install mssql-tools \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/*
