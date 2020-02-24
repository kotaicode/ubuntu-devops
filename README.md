# docker devops image

ubuntu image with additional tools installed to run typical devops tasks.
comes with:

**cloud:**

  - AWS CLI
  - Google Cloud platform SDK
  - MS Azure CLI

**programming:**

  - go
  - python
  - ruby
  - nodejs
  - make
  - git

**clients:**

  - rabbitmq
  - mysql
  - postgres
  - redis
  - mongo

**editors:**

  - vim (with plugins)
  - nano

**tools:**

  - silversearcher
  - curl
  - dnsutils

# usage

run a shell in your kubernetes cluster using:
```
kubectl run --generator=run-pod/v1 my-shell --rm -i --tty --image kotaicode/ubuntu-devops -- bash
```

