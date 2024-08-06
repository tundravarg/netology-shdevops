FROM ubuntu:24.10

RUN apt update -y
RUN apt install -y bash
RUN apt install -y python3
RUN apt install -y openssh-server
RUN apt install -y vim
RUN apt install -y sudo

ARG ANSIBLE_USERNAME
ARG ANSIBLE_PASSWORD
ENV ANSIBLE_USERNAME ${ANSIBLE_USERNAME}
ENV ANSIBLE_PASSWORD ${ANSIBLE_PASSWORD}

RUN useradd "${ANSIBLE_USERNAME}" && \
    printf "${ANSIBLE_PASSWORD}\n${ANSIBLE_PASSWORD}" | passwd "${ANSIBLE_USERNAME}" && \
    usermod -aG sudo "${ANSIBLE_USERNAME}" && \
    mkdir -p "/home/${ANSIBLE_USERNAME}" && \
    chown "${ANSIBLE_USERNAME}:${ANSIBLE_USERNAME}" /home/"${ANSIBLE_USERNAME}"

WORKDIR /init

COPY init-main.sh ./
COPY init-ubuntu.sh ./init.sh

CMD [ "bash", "init.sh" ]
