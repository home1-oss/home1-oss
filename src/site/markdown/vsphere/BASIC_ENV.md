# 部分基本环境配置

1. [docker安装](../DOCKER_INSTALL.md),[docker使用相关。](../DOCKER_COMMANDS_AND_ISSUES.md)

  ***注意***: k8s对docker的版本有要求，需要按照对应的版本，在k8s的节点上安装相应的docker版本,查看[Supported Docker version](http://docs.rancher.com/rancher/v1.6/en/hosts/#supported-docker-versions)。

2. docker-compose相关，[官网教程](https://docs.docker.com/compose/install/)

  以 CentOS7 为例:
      
        curl -L https://github.com/docker/compose/releases/download/1.12.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose  
        chmod +x /usr/local/bin/docker-compose     
      
3. docker环境设置，设置加速镜像以及私有镜像库(加速镜像地址可以改，私有镜像库域名不要改动，后边dns有讲到)。

        sudo mkdir -p /etc/docker
        sudo tee /etc/docker/daemon.json <<-'EOF'
        {
            "registry-mirrors": ["https://xt3b6cxm.mirror.aliyuncs.com","http://hub-mirror.c.163.com"],
            "insecure-registries": ["registry.docker.internal","registry.docker.yixinonline.org"]
        }
        EOF
        sudo systemctl daemon-reload
        sudo systemctl restart docker

4. **DNS配置**
      
    ***DNS服务器*** 
    要修改 `/etc/sysconfig/network-scripits/ifc-xxx` 这个文件中你的DNS，改/etc/reslov.conf是不行的，重启后就还原了。
     
5. 其他，比如

    - 关闭防火墙之类。
    - 设置静态IP
    - 设置hostname,比如centos7系统的话，使用`hostnamectl set-hostname xxx` 来进行。  