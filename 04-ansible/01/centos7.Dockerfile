FROM centos:7

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum install -y openssh-server
RUN yum install -y sudo
RUN yum install -y python3

RUN cd /etc/ssh && ssh-keygen -A

ARG ANSIBLE_USERNAME
ARG ANSIBLE_PASSWORD
ENV ANSIBLE_USERNAME ${ANSIBLE_USERNAME}
ENV ANSIBLE_PASSWORD ${ANSIBLE_PASSWORD}

RUN useradd "${ANSIBLE_USERNAME}" && \
    printf "${ANSIBLE_PASSWORD}\n${ANSIBLE_PASSWORD}" | passwd "${ANSIBLE_USERNAME}" && \
    usermod -aG wheel "${ANSIBLE_USERNAME}" && \
    mkdir -p "/home/${ANSIBLE_USERNAME}" && \
    chown "${ANSIBLE_USERNAME}:${ANSIBLE_USERNAME}" /home/"${ANSIBLE_USERNAME}"

WORKDIR /init

COPY init-main.sh ./
COPY init-centos7.sh ./init.sh

CMD [ "bash", "init.sh" ]
