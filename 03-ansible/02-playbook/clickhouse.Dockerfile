FROM fedora:40

RUN yum install -y python3
RUN yum install -y procps iputils net-tools

WORKDIR /root

CMD [ "sleep", "1d" ]
