# 安装jenkins

## 准备

### 配置DNS映射

该项目用到的域名是`jenkins.internal`

### 克隆项目

- 克隆docker-jenkins项目 `git clone git@github.com:home1-oss/docker-jenkins.git`

#### 设置环境变量

修改 .bashrc 文件，增加如下内容

    export JENKINS_HOSTNAME=jenkins.internal

执行 source .bashrc

#### 启动Jenkins

- 定位到jenkins目录下 `cd docker-jenkins/jenkins/`
- 启动 `docker-compose up -d`
- 如果遇到提示oss-network网络未创建，直接复制命令`docker network create oss-network`创建即可
- 等待启动完成，通过 http://jenkins.internal:18083 访问测试(第一次访问，需要复制docker容器日志中的密码字段，在页面输入)
- 创建admin用户