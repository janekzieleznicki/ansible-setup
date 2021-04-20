# Ansible linux setup


## Run on localhost
```bash
ansible-playbook -e user=$USER  -e install_tools=false --connection=local --inventory localhost, -K main.yml
```

