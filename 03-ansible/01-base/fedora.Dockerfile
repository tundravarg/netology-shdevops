FROM fedora:40

RUN yum install -y python3

WORKDIR /init

COPY init.sh ./

CMD [ "bash", "init.sh" ]
