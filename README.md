* install
  - sudo make install 

* import zabbix template 
  - import zbx_nvidia-smi-multi-gpu.xml to zabbix Templates
  - create GPU-Number and GPU-Avg-Utilization Graphs
  - select host and Add Template Nvidia GPUs Performance

* restart zabbix-agentd
  - bash restart.sh

* docker
  - build image
  - build container
