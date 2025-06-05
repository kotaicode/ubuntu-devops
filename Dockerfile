FROM ubuntu:24.04
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
  magic-wormhole \
  make \
  mysql-client \
  nano \
  postgresql-client \
  python3-all-dev \
  python3-pip \
  python3-setuptools \
  python3.6 \
  redis-tools \
  ruby-full \
  silversearcher-ag \
  ssh-client \
  tmux \
  unzip \
  vim \
  wget \
  yamllint \
  inetutils-ping \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# install yq
ENV YQ_VERSION="4.40.5"
RUN wget https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install

# Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# GCloud SDK
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
apt-get update && apt-get install  -y --no-install-recommends google-cloud-cli

# install go
ENV GO_VERSION="1.24.1"
RUN wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
ENV GOROOT=/usr/local/go
ENV PATH=$PATH:/usr/local/go/bin

# RABBITMQ tooling
ENV RABBITMQ_ADMIN_VERSION="3.7.15"
RUN wget https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/v${RABBITMQ_ADMIN_VERSION}/bin/rabbitmqadmin -O ~/rabbitmqadmin
RUN chmod +x ~/rabbitmqadmin
RUN mv ~/rabbitmqadmin /usr/bin/

#install rabtap
ENV RABTAP_VERSION="1.39.1"
RUN wget https://github.com/jandelgado/rabtap/releases/download/v${RABTAP_VERSION}/rabtap_${RABTAP_VERSION}_linux_amd64.tar.gz && \
    tar -xzf rabtap_${RABTAP_VERSION}_linux_amd64.tar.gz && \
    mv rabtap /usr/bin/ && \
    rm rabtap_${RABTAP_VERSION}_linux_amd64.tar.gz

# install terraform
ENV TERRAFORM_VERSION="1.6.6"
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
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
RUN curl -sL https://deb.nodesource.com/setup_20.x  | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get -y install nodejs yarn \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# jsonlint
RUN npm install jsonlint -g

# install kubectl
ENV KUBECTL_VERSIONS="1.24.0 1.25.0 1.26.0"
ENV KUBECTL_INSTALL_DIR=/usr/local/bin
COPY install-kubectl.sh /tmp/install-kubectl.sh
RUN /tmp/install-kubectl.sh
ENV PATH=$PATH:$KUBECTL_INSTALL_DIR
RUN echo 'source k8s_aliases' >> ~/.bashrc

#mssql-cli
#RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
#    && curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/20.04/prod.list
#
#RUN apt-get update && apt-get -y install mssql-tools \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/*
