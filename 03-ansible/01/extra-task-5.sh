#!/bin/bash

docker compose up --build -d &&

cd playbook &&
ansible-playbook site.yml -i inventory/prod.yml --vault-password-file ../.ansible-vault-pwd &&
cd .. &&

docker compose down &&
docker compose rm -f &&

echo "DONE" || { echo "FAIL"; exit 1; }
