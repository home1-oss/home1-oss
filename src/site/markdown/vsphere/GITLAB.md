# 安装gitlab server

## 准备

### DNS 配置解析

该服务用到一个域名 `gitlab.internal`

### 克隆相关项目

- 克隆oss-gitlab项目 `git clone git@github.com:home1-oss/docker-gitlab.git`
- 克隆***其他需要上传到gitlab的项目***，放到***同级***目录。

### 设置环境变量

修改 .bashrc 文件，增加如下内容

    export DOCKER_REGISTRY=registry.docker.internal  ##docker 仓库
    export GIT_HOSTNAME=gitlab.internal                      ##gitlab的域名
    export CONFIGSERVER_WEBHOOK_ENDPOINT=http://k8s.node1.internal:30000/monitor ##configserver回调地址 k8s nodeport方式指定node端口范围是30000-32767,conigserver指定30000

执行 source .bashrc

#### 启动gitlab

- 定位到gitlab目录下 `cd docker-gitlab/gitlab/`
- 启动 `docker-compose up -d` 
- 如果遇到提示oss-network网络未创建，直接复制命令 `docker network create oss-network` 创建即可
- 等待启动完成，通过 http://gitlab.internal (端口在docker-compose文件中，最好改成80，gitlab-runner文档中有说明)访问测试 root/oss_pass,oss/oss_pass

***安装中发现一个问题，使用163 docker镜像加速的话，构建镜像时去mirrors.163.com下载东西时会出现问题，这时候先去掉docker的163镜像加速再安装即可***