# Домашнее задание к занятию 5 «Тестирование roles»


> - Ваша цель - настроить тестирование ваших ролей.
> - Задача - сделать сценарии тестирования для vector.
> - Ожидаемый результат - все сценарии успешно проходят тестирование ролей.


## Подготовка к выполнению


> 1. Установите molecule и его драйвера: `pip3 install "molecule molecule_docker molecule_podman`.

```
Tuman$ pip3 install molecule molecule_docker molecule_podman
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: molecule in /home/sergey/.local/lib/python3.10/site-packages (24.8.0)
Collecting molecule_docker
  Downloading molecule_docker-2.1.0-py3-none-any.whl (18 kB)
Collecting molecule_podman
  Downloading molecule_podman-2.0.3-py3-none-any.whl (15 kB)
Requirement already satisfied: Jinja2>=2.11.3 in /home/sergey/.local/lib/python3.10/site-packages (from molecule) (3.1.4)
Requirement already satisfied: pluggy<2.0,>=0.7.1 in /home/sergey/.local/lib/python3.10/site-packages (from molecule) (1.5.0)
Requirement already satisfied: ansible-core>=2.12.10 in /home/sergey/.local/lib/python3.10/site-packages (from molecule) (2.16.9)
Requirement already satisfied: PyYAML>=5.1 in /usr/lib/python3/dist-packages (from molecule) (5.4.1)
Requirement already satisfied: enrich>=1.2.7 in /home/sergey/.local/lib/python3.10/site-packages (from molecule) (1.2.7)
Requirement already satisfied: click<9,>=8.0 in /usr/lib/python3/dist-packages (from molecule) (8.0.3)
Requirement already satisfied: jsonschema>=4.9.1 in /home/sergey/.local/lib/python3.10/site-packages (from molecule) (4.23.0)
Requirement already satisfied: ansible-compat>=24.6.1 in /home/sergey/.local/lib/python3.10/site-packages (from molecule) (24.7.0)
Requirement already satisfied: wcmatch>=8.1.2 in /home/sergey/.local/lib/python3.10/site-packages (from molecule) (9.0)
Requirement already satisfied: click-help-colors in /home/sergey/.local/lib/python3.10/site-packages (from molecule) (0.9.4)
Requirement already satisfied: packaging in /home/sergey/.local/lib/python3.10/site-packages (from molecule) (24.1)
Requirement already satisfied: rich>=9.5.1 in /home/sergey/.local/lib/python3.10/site-packages (from molecule) (13.7.1)
Collecting selinux
  Downloading selinux-0.3.0-py2.py3-none-any.whl (4.2 kB)
Requirement already satisfied: requests in /usr/lib/python3/dist-packages (from molecule_docker) (2.25.1)
Collecting docker>=4.3.1
  Downloading docker-7.1.0-py3-none-any.whl (147 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 147.8/147.8 KB 2.2 MB/s eta 0:00:00
Requirement already satisfied: subprocess-tee>=0.4.1 in /home/sergey/.local/lib/python3.10/site-packages (from ansible-compat>=24.6.1->molecule) (0.4.2)
Requirement already satisfied: cryptography in /usr/lib/python3/dist-packages (from ansible-core>=2.12.10->molecule) (3.4.8)
Requirement already satisfied: resolvelib<1.1.0,>=0.5.3 in /home/sergey/.local/lib/python3.10/site-packages (from ansible-core>=2.12.10->molecule) (1.0.1)
Collecting requests
  Downloading requests-2.32.3-py3-none-any.whl (64 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 64.9/64.9 KB 8.4 MB/s eta 0:00:00
Requirement already satisfied: urllib3>=1.26.0 in /usr/lib/python3/dist-packages (from docker>=4.3.1->molecule_docker) (1.26.5)
Requirement already satisfied: MarkupSafe>=2.0 in /usr/lib/python3/dist-packages (from Jinja2>=2.11.3->molecule) (2.0.1)
Requirement already satisfied: referencing>=0.28.4 in /home/sergey/.local/lib/python3.10/site-packages (from jsonschema>=4.9.1->molecule) (0.35.1)
Requirement already satisfied: jsonschema-specifications>=2023.03.6 in /home/sergey/.local/lib/python3.10/site-packages (from jsonschema>=4.9.1->molecule) (2023.12.1)
Requirement already satisfied: attrs>=22.2.0 in /home/sergey/.local/lib/python3.10/site-packages (from jsonschema>=4.9.1->molecule) (24.2.0)
Requirement already satisfied: rpds-py>=0.7.1 in /home/sergey/.local/lib/python3.10/site-packages (from jsonschema>=4.9.1->molecule) (0.20.0)
Collecting charset-normalizer<4,>=2
  Downloading charset_normalizer-3.3.2-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (142 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 142.1/142.1 KB 10.8 MB/s eta 0:00:00
Requirement already satisfied: idna<4,>=2.5 in /usr/lib/python3/dist-packages (from requests->molecule_docker) (3.3)
Requirement already satisfied: certifi>=2017.4.17 in /usr/lib/python3/dist-packages (from requests->molecule_docker) (2020.6.20)
Requirement already satisfied: pygments<3.0.0,>=2.13.0 in /home/sergey/.local/lib/python3.10/site-packages (from rich>=9.5.1->molecule) (2.18.0)
Requirement already satisfied: markdown-it-py>=2.2.0 in /home/sergey/.local/lib/python3.10/site-packages (from rich>=9.5.1->molecule) (3.0.0)
Requirement already satisfied: bracex>=2.1.1 in /home/sergey/.local/lib/python3.10/site-packages (from wcmatch>=8.1.2->molecule) (2.5)
Requirement already satisfied: distro>=1.3.0 in /usr/lib/python3/dist-packages (from selinux->molecule_docker) (1.7.0)
Requirement already satisfied: mdurl~=0.1 in /home/sergey/.local/lib/python3.10/site-packages (from markdown-it-py>=2.2.0->rich>=9.5.1->molecule) (0.1.2)
Installing collected packages: selinux, charset-normalizer, requests, docker, molecule_podman, molecule_docker
Successfully installed charset-normalizer-3.3.2 docker-7.1.0 molecule_docker-2.1.0 molecule_podman-2.0.3 requests-2.32.3 selinux-0.3.0
```


> 2. Выполните `docker pull aragast/netology:latest` —  это образ с podman, tox и несколькими пайтонами (3.7 и 3.9) внутри.

```
Tuman$ docker pull aragast/netology:latest
latest: Pulling from aragast/netology
f70d60810c69: Pull complete
545277d80005: Pull complete
3787740a304b: Pull complete
8099be4bd6d4: Pull complete
78316366859b: Pull complete
a887350ff6d8: Pull complete
8ab90b51dc15: Pull complete
14617a4d32c2: Pull complete
b868affa868e: Pull complete
1e0b58337306: Pull complete
9167ab0cbb7e: Pull complete
907e71e165dd: Pull complete
6025d523ea47: Pull complete
6084c8fa3ce3: Pull complete
cffe842942c7: Pull complete
d984a1f47d62: Pull complete
Digest: sha256:e44f93d3d9880123ac8170d01bd38ea1cd6c5174832b1782ce8f97f13e695ad5
Status: Downloaded newer image for aragast/netology:latest
docker.io/aragast/netology:latest

What's Next?
  View a summary of image vulnerabilities and recommendations → docker scout quickview aragast/netology:latest
```


В этом задании необходимо модифицировать сделанный и отлаженный ранее playbook.
Поэтому за основу возьмём (скопируем) terraform и playbook из предыдущего задания.

Не забываем переименовать проект.

terraform/main.tf:

```diff
-    default = "ntlg-a4"
+    default = "ntlg-a5"
```

playbook/group_vars/all/vars.yml:

```diff
-project_name: ntlg-a4
+project_name: ntlg-a5
```

Создаём ВМ:

```
terraform apply
```

Устанавливаем роли из `requirements.yml` и накатываем изменения:

```shell
ansible-galaxy install -r requirements.yml -p roles
ansible-playbook site.yml -i inventory/prod.yml -t test
ansible-playbook site.yml -i inventory/prod.yml
```


## Molecule ClickHouse


> 1. Запустите  `molecule test -s ubuntu_xenial` (или с любым другим сценарием, не имеет значения) внутри корневой директории clickhouse-role, посмотрите на вывод команды. Данная команда может отработать с ошибками или не отработать вовсе, это нормально. Наша цель - посмотреть как другие в реальном мире используют молекулу И из чего может состоять сценарий тестирования.


```
$ molecule test -s ubuntu_xenial
CRITICAL 'molecule/ubuntu_xenial/molecule.yml' glob failed.  Exiting.
```

NOTE: Странная проблема... Решается убиранием каталога `roles` из `.gitignore`.

```
$ molecule test -s ubuntu_xenial
WARNING  Driver docker does not provide a schema.
CRITICAL Failed to validate /home/sergey/Documents/Work/Netology/netology-shdevops/03-ansible/05/playbook/roles/clickhouse/molecule/ubuntu_xenial/molecule.yml

["Additional properties are not allowed ('playbooks' was unexpected)"]
```

Выпиливаем параметр:

```diff
verifier:
  name: ansible
-  playbooks:
-    verify: ../resources/tests/verify.yml
+  # playbooks:
+  #   verify: ../resources/tests/verify.yml
```

Что-то заработало:

```
$ molecule test -s ubuntu_xenial
WARNING  Driver docker does not provide a schema.
INFO     ubuntu_xenial scenario test matrix: dependency, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
INFO     Performing prerun with role_name_check=0...
INFO     Running ubuntu_xenial > dependency
WARNING  Skipping, missing the requirements file.
WARNING  Skipping, missing the requirements file.
INFO     Running ubuntu_xenial > cleanup
WARNING  Skipping, cleanup playbook not configured.
INFO     Running ubuntu_xenial > destroy
INFO     Sanity checks: 'docker'

PLAY [Destroy] *****************************************************************

TASK [Set async_dir for HOME env] **********************************************
ok: [localhost]

TASK [Destroy molecule instance(s)] ********************************************
changed: [localhost] => (item=ubuntu_xenial)

TASK [Wait for instance(s) deletion to complete] *******************************
FAILED - RETRYING: [localhost]: Wait for instance(s) deletion to complete (300 retries left).
ok: [localhost] => (item=ubuntu_xenial)

TASK [Delete docker networks(s)] ***********************************************
skipping: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Running ubuntu_xenial > syntax

playbook: /home/sergey/Documents/Work/Netology/netology-shdevops/03-ansible/05/playbook/roles/clickhouse/molecule/resources/playbooks/converge.yml
INFO     Running ubuntu_xenial > create

PLAY [Create] ******************************************************************

TASK [Set async_dir for HOME env] **********************************************
ok: [localhost]

TASK [Log into a Docker registry] **********************************************
skipping: [localhost] => (item=None)
skipping: [localhost]

TASK [Check presence of custom Dockerfiles] ************************************
ok: [localhost] => (item={'capabilities': ['SYS_ADMIN'], 'command': '/sbin/init', 'dockerfile': '../resources/Dockerfile.j2', 'env': {'ANSIBLE_USER': 'ansible', 'DEPLOY_GROUP': 'deployer', 'SUDO_GROUP': 'sudo', 'container': 'docker'}, 'image': 'ubuntu:xenial', 'name': 'ubuntu_xenial', 'privileged': True, 'tmpfs': ['/run', '/tmp'], 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup']})

TASK [Create Dockerfiles from image names] *************************************
changed: [localhost] => (item={'capabilities': ['SYS_ADMIN'], 'command': '/sbin/init', 'dockerfile': '../resources/Dockerfile.j2', 'env': {'ANSIBLE_USER': 'ansible', 'DEPLOY_GROUP': 'deployer', 'SUDO_GROUP': 'sudo', 'container': 'docker'}, 'image': 'ubuntu:xenial', 'name': 'ubuntu_xenial', 'privileged': True, 'tmpfs': ['/run', '/tmp'], 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup']})

TASK [Synchronization the context] *********************************************
changed: [localhost] => (item={'capabilities': ['SYS_ADMIN'], 'command': '/sbin/init', 'dockerfile': '../resources/Dockerfile.j2', 'env': {'ANSIBLE_USER': 'ansible', 'DEPLOY_GROUP': 'deployer', 'SUDO_GROUP': 'sudo', 'container': 'docker'}, 'image': 'ubuntu:xenial', 'name': 'ubuntu_xenial', 'privileged': True, 'tmpfs': ['/run', '/tmp'], 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup']})

TASK [Discover local Docker images] ********************************************
ok: [localhost] => (item=None)
ok: [localhost]

TASK [Build an Ansible compatible image (new)] *********************************
ok: [localhost] => (item=molecule_local/ubuntu:xenial)

TASK [Create docker network(s)] ************************************************
skipping: [localhost]

TASK [Determine the CMD directives] ********************************************
ok: [localhost] => (item=None)
ok: [localhost]

TASK [Create molecule instance(s)] *********************************************
changed: [localhost] => (item=ubuntu_xenial)

TASK [Wait for instance(s) creation to complete] *******************************
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (300 retries left).
changed: [localhost] => (item=None)
changed: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=9    changed=4    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0

INFO     Running ubuntu_xenial > prepare
WARNING  Skipping, prepare playbook not configured.
INFO     Running ubuntu_xenial > converge

PLAY [Converge] ****************************************************************

TASK [Gathering Facts] *********************************************************
fatal: [ubuntu_xenial]: FAILED! => {"ansible_facts": {}, "changed": false, "failed_modules": {"ansible.legacy.setup": {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3"}, "failed": true, "msg": "ansible-core requires a minimum of Python2 version 2.7 or Python3 version 3.6. Current version: 3.5.2 (default, Jan 26 2021, 13:30:48) [GCC 5.4.0 20160609]"}}, "msg": "The following modules failed to execute: ansible.legacy.setup\n"}

PLAY RECAP *********************************************************************
ubuntu_xenial              : ok=0    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0

CRITICAL Ansible return code was 2, command was: ansible-playbook -D --inventory /home/sergey/.cache/molecule/clickhouse/ubuntu_xenial/inventory --skip-tags molecule-notest,notest /home/sergey/Documents/Work/Netology/netology-shdevops/03-ansible/05/playbook/roles/clickhouse/molecule/resources/playbooks/converge.yml
WARNING  An error occurred during the test sequence action: 'converge'. Cleaning up.
INFO     Running ubuntu_xenial > cleanup
WARNING  Skipping, cleanup playbook not configured.
INFO     Running ubuntu_xenial > destroy

PLAY [Destroy] *****************************************************************

TASK [Set async_dir for HOME env] **********************************************
ok: [localhost]

TASK [Destroy molecule instance(s)] ********************************************
changed: [localhost] => (item=ubuntu_xenial)

TASK [Wait for instance(s) deletion to complete] *******************************
FAILED - RETRYING: [localhost]: Wait for instance(s) deletion to complete (300 retries left).
changed: [localhost] => (item=ubuntu_xenial)

TASK [Delete docker networks(s)] ***********************************************
skipping: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=3    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Pruning extra files from scenario ephemeral directory
```
