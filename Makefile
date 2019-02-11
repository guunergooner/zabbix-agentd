conf_path=/etc/zabbix/zabbix_agent.d
scripts_path=/etc/zabbix/scripts

all:
	@echo "usage: make install"

install: install-requirement install-agent-config install-scripts set-config

install-requirement:
	yum clean all && rpm -Uvh \
		https://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
	yum -y install zabbix-agent python-pip
	pip install --upgrade pip && pip install nvidia-ml-py

install-agent-config:
	install -o root -g root -m 644 userparameter_nvidia-smi.conf /etc/zabbix/zabbix_agentd.d

install-scripts:
	install -d -o root -g root -m 755 ${scripts_path}
	install -o root -g root -m 755 \
		get_gpus_info.sh nvidia-ml.py set_zabbix_config.sh ${scripts_path}

set-config:
	bash ${scripts_path}/set_zabbix_config.sh 

clean:
	test ! -d ${conf_path} || rm -rf ${conf_path} 
	test ! -d ${scripts_path} || rm -rf ${scripts_path} 
