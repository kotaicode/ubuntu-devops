FROM ubuntu:18.04
RUN apt-get update && apt-get install -y --no-install-recommends \
  apache2-utils \
  apt-transport-https \
  build-essential \
  ca-certificates \
  curl \
  dnsutils \
  git \
  gnupg \
  libffi-dev \
  libssl-dev \
  lsb-release \
  make \
  mysql-client \
  nano \
  postgresql-client \
  python-dev \
  python-pip \
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

# AWS CLI
RUN pip install aws-shell
RUN pip install awscli

# Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/azure-cli.list
RUN apt-get update && apt-get install -y azure-cli \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# GCloud SDK
ENV GCLOUD_SDK_VERSION="256.0.0"
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar -xzvf google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    /google-cloud-sdk/install.sh -q && \
    ln -s /google-cloud-sdk/bin/* /usr/local/bin && \
    gcloud --version && \
    rm google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz

# install go
RUN wget https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz
RUN tar -xvf go1.12.6.linux-amd64.tar.gz
RUN mv go /usr/local
ENV GOROOT=/usr/local/go
ENV PATH=$PATH:/usr/local/go/bin

# RABBITMQ tooling
RUN wget https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/v3.7.15/bin/rabbitmqadmin -O ~/rabbitmqadmin
RUN chmod +x ~/rabbitmqadmin
RUN mv ~/rabbitmqadmin /usr/bin/
#install rabtap
RUN GO111MODULE=on go get github.com/jandelgado/rabtap/cmd/rabtap


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
RUN wget -qO - https://www.mongodb.org/static/pgp/server-4.0.asc | apt-key add -
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list
RUN apt-get update && apt-get install -y mongodb-org-tools mongodb-org-shell
