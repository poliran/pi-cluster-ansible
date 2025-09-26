.PHONY: help install deploy check lint clean

help:
	@echo "Available commands:"
	@echo "  install  - Install Ansible dependencies"
	@echo "  deploy   - Deploy the full cluster"
	@echo "  check    - Run syntax check"
	@echo "  lint     - Run ansible-lint"
	@echo "  clean    - Clean logs and temporary files"

install:
	ansible-galaxy install -r requirements.yml

deploy:
	ansible-playbook playbooks/site.yml --ask-vault-pass

check:
	ansible-playbook playbooks/site.yml --syntax-check --ask-vault-pass

lint:
	ansible-lint playbooks/site.yml

clean:
	rm -f logs/*.log
	rm -f *.retry
