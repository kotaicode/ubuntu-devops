# docker devops image

ubuntu image with additional tools installed to run typical devops tasks.
comes with: vim, go, python, ruby, clients for redis, rabbitmq, mysql, postgres

# usage

run a shell in your kubernetes cluster using:
```
kubectl run --generator=run-pod/v1 my-shell --rm -i --tty --image kotaicode/ubuntu-devops -- bash
```

