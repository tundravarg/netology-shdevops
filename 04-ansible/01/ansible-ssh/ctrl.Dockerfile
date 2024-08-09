FROM alpine:3.20.2

RUN apk update
RUN apk add openssh sshpass
RUN apk add python3 pipx
RUN apk add bash vim

RUN pipx install --include-deps ansible==9.8.0 && \
    pipx ensurepath

WORKDIR /init

COPY init-main.sh ./
COPY init-ctrl.sh ./init.sh

CMD [ "bash", "init.sh" ]
