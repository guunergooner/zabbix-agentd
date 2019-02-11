FROM nvidia/cuda:9.0-runtime-centos7
LABEL manitainer "Rokid Corporation"

# install yum package
RUN yum install -y epel-release
RUN rpm -Uvh \
        https://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm

RUN yum install -y \
        sudo \
        python-pip \
        zabbix-agent

# timezone
ARG TIMEZONE
RUN echo $TIMEZONE > /etc/timezone && \
        ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

# user 
ARG USER_NAME
ARG USER_ID=1000
RUN groupadd -g $USER_ID $USER_NAME && \
        useradd -ms /bin/bash -u $USER_ID -g $USER_ID $USER_NAME && \
        echo "$USER_NAME    ALL=(ALL)    NOPASSWD:ALL" >> /etc/sudoers

# clean
RUN yum clean all && rm -rf /var/cache/yum

# copy file
RUN mkdir -p /home/$USER_NAME/zabbix
COPY requirements.txt userparameter_nvidia-smi.conf \
    get_gpus_info.sh nvidia-ml.py run-zabbix-agent.sh \
    /home/$USER_NAME/zabbix/
RUN chown -R $USER_NAME:$USER_NAME /home/$USER_NAME/zabbix

# install pip package
RUN cd /home/$USER_NAME/zabbix && \
        pip install -r requirements.txt

# install scripts
ARG SERVER_ADDR
RUN cd /home/$USER_NAME/zabbix && \
        install -o root -g root -m 644 userparameter_nvidia-smi.conf /etc/zabbix/zabbix_agentd.d && \
        install -d -o root -g root -m 755 /etc/zabbix/scripts && \
        install -o root -g root -m 755 get_gpus_info.sh nvidia-ml.py /etc/zabbix/scripts && \
        sed -i "s/$(grep 'AllowRoot=' /etc/zabbix/zabbix_agentd.conf)/AllowRoot=1/g" \
        /etc/zabbix/zabbix_agentd.conf && \
        sed -i "s/$(grep 'Server=' /etc/zabbix/zabbix_agentd.conf | grep -v '#')/Server=${SERVER_ADDR}/g" \
        /etc/zabbix/zabbix_agentd.conf && \
        sed -i "s/$(grep 'ServerActive=' /etc/zabbix/zabbix_agentd.conf | grep -v '#')/ServerActive=${SERVER_ADDR}/g" \
        /etc/zabbix/zabbix_agentd.conf

USER $USER_NAME
