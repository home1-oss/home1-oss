# 安装jenkins slave

## 准备


#### 创建slave账户

登录Jenkins后添加账户 swarm/swarm_pass (**注意** 配置ldap用户体系后，需要切换回原来的用户体系来增加，或者修改配置文件中对应的账号密码即可)

### 克隆相关项目

- 克隆docker-jenkins项目 `git clone git@github.com:home1-oss/docker-jenkins.git`

- 若是要部署到k8s环境则直接使用k8s目录下的k8s配置文件部署即可，否则接着往下操作。(` kubectl create -f XXX.yaml`)


#### 设置环境变量

修改 .bashrc 文件，增加如下内容

    export DOCKER_REGISTRY=registry.docker.yixinonline.org      ##docker镜像仓库
    export JENKINS_SLAVE_HOSTNAME=jenkinsslave.internal         ##salave节点域名
    export GIT_SERVICE_TOKEN=Q2Sa-yVnoxvmmn1szpBR               ##同gitlab runner.md文档相同
    export JENKINS_PORT_8080_TCP_ADDR=jenkins.internal          ##jenkins域名
    export JENKINS_PORT_8080_TCP_PORT=18083   #注意 slave要是和Jenkins部署在同一太机器的话，这个端口要写成容器的端口 即8080                  ##jenkins端口

执行 source .bashrc

因为有从容器内部访问外部 docker service 的需求，需要修改宿主机的/var/run/docker.sock文件访问权限.

    sudo chmod a+rw /var/run/docker.sock


#### 启动 salve节点

- 定位到jenkins-swarm-slave目录下 `cd docker-jenkins/jenkins-swarm-slave/`
- 启动 `docker-compose up -d`
- 如果遇到提示oss-network网络未创建，直接复制命令创建即可
- 等待启动完成，登录jenkins验证安装