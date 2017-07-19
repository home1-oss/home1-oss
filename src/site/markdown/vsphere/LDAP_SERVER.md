# 安装ldap

## 准备

### 配置DNS解析

改项目有两个域名，ldap.internal , ldapadmin.internal 。

### 克隆相关项目
- 克隆oss-docker项目 `git@github.com:home1-oss/oss-docker.git`

### 设置环境变量

修改 ~/.bashrc 文件，增加如下内容

    export DOCKER_REGISTRY=registry.docker.internal
    export LDAP_HOSTNAME=ldap.internal
    export LDAP_DOMAIN=internal
    export LDAPADMIN_HOSTNAME=ldapadmin.internal
    export LDAP_ORGANISATION=xxx   ## 组织信息 Example
    export LDAP_ADMIN_PASSWORD=xxx ##密码 默认admin_pass

执行  `source .bashrc`

## 启动LDAP

- 定位到ldap目录下 `cd oss-docker/ldap/`
- 启动 `docker-compose up -d`
- 如果遇到提示oss-network网络未创建，直接复制命令`﻿docker network create oss-network`创建即可
- 等待启动完成，通过 https://ldapadmin.internal:6443/ 账户信息: cn=admin,dc=internal/admin_pass