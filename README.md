# clear-r Docker file

Docker file for R on clearlinux

To install and push to dockerhub manually,

```bash
sudo docker build --no-cache -t [docker-USERNAME]/clear-r . # replace [docker-USERNAME] with your docker usename
sudo docker login
sudo docker push [docker-USERNAME]/clear-r # replace [docker-USERNAME] with your docker usename
```

