FROM ubuntu:24.10

RUN apt update -y
RUN apt install -y python3

WORKDIR /init

COPY init.sh ./

CMD [ "bash", "init.sh" ]
