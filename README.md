# clear-r Docker file

Docker file for R on clearlinux

To install and push to Docker hub manually,

```bash
sudo docker build --no-cache -t [docker-USERNAME]/clear-r . # replace [docker-USERNAME] with your Docker username
sudo docker login
sudo docker push [docker-USERNAME]/clear-r # replace [docker-USERNAME] with your Docker username
```

