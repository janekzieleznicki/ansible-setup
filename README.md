# Ansible linux setup


## Run on localhost
```bash
ansible-playbook -e user=$USER  --skip-tags="virtools" --connection=local --inventory localhost, -K main.yml
```

