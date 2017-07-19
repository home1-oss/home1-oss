# oss 各系统搭建使用流程

<!-- vim-markdown-toc GFM -->
* [环境准备](#准备工作)
* [业务基础服务](#业务基础服务)
  * [nexus3](#nexus3)
  * [gitlab-server](#gitlab-server)
  * [jenkins](#jenkins)
  * [sonarquebe](#sonarquebe)
* [rancher+k8s](#验证测试)
  * [rancher](#rancher)
  * [k8s](#k8s)
  * [gitlab ci runner](#gitlab_ci_runner)
* [正常开发注意事项](#正常开发注意事项)
  * [oss-internal](#oss-internal)
  * [oss-jenkins-pipelin](#oss-jenkins-pipelin)
* [TODO](#TODO)

<!-- vim-markdown-toc -->
 
 
 
## 准备工作

基础环境和服务
  
1. 准备好一定数量的虚拟机节点，安装相应的环境，[docker,docker-compose,docker私有仓库、加速设置](BASIC_ENV.md)，ssh访问，网络(k8s需***翻墙***)等等。

2. DNS配置，oss项目使用自定义域名internal,所以需要搭建自己的服务器来服务于项目。查看[DNS服务器搭建](DNS_SERVER.md)
   
    需要配置如下域名(各项目搭建时，有详细说明):

        k8s.internal                        #k8s-server       k8s服务器节点IP  
        node1.k8s.internal                  #k8s-node x       k8s服务x节点IP  
        gitlab.internal                     #gitlab-server    gitlab服务节点IP
        jenkins.internal                    #jenkins          jenkins服务节点IP
        ldap.internal                       #ldap-server      ldap服务节点IP
        ldapadmin.internal                  #ldap-admin       ldap admin后台，与ldapserver部署在同一服务器，故IP相同 
        nexus.internal                      #nexus3           nexus3服务器节点IP
        mirror.docker.internal              #docker-mirror    nexus3提供的功能 IP同nexus3
        registry.docker.internal            #docker-registry  nexus3提供的功能 IP同nexus3
        fileserver.internal                 #file-server      nexus3提供的功能 IP同nexus3
        mvn-site.infra.internal             #mvn-site-server  nexus3提供的功能 IP同nexus3
        sonarqube.internal                  #sonarqube        sonarqube 节点IP

    **注意**: 搭建过程中每台机器都要配置DNS服务器地址，配置方法在安装文档中。 
   
3. LDAP服务搭建，实现统一的用户管理，查看[LDAP服务器搭建](LDAP_SERVER.md)  

    - [通过访问后台进行管理,全部界面化操作简单明了](https://ldapadmin.internal:6443) 账户信息: cn=admin,dc=internal/admin_pass，比如LDAP创建用户可按照[此文档](LDAP_ADDUSER_BY_LDAPADMIN.md)进行配置。
    - 进入docker容器内部直接使用 `ldapadd` 进行操作，略。

## 业务基础服务

***注意*** 当服务搭建在一台服务器上时(比如jenkins和gitlab,当容器内部访问服务时，端口需要设置成容器内部端口)

举例： gitlab 的ssh端口映射为 20022:22 即宿主机20022，容器22，若是同一台机器的jenkins的内部访问则访问22，其他机器访问则访问20022


### nexus3 

1. [nexus3安装](NEXUS3.md) 
2. 使用admin/admin123登录后台，[配置LDAP](NEXUS3_LDAP.md)
3. 默认使用deployment/deployment账户最为maven deploy账户，若要修改秘钥同时需修改oss-internal,maven settings中的内容。


### gitlab-server

1. [gitlab-server安装](GITLAB.md)  //TODO 与外面GITLAB.md的关系。
2. [gitlab配置ldap](GITLAB_LDAP.md) 

3. 项目相关(**注意** 引入项目时分别放在`home1oss`，`configserver`组之下，若下所示 组名/项目名)

    gitlab上的服务初始化如下项目

    - home1oss/oss-internal                     存放项目一些敏感信息，有些需要更新比如***k8s***的配置
   
    gitlab搭建完毕后，可从github引入样例项目

    - home1oss/oss-jenkins-pipeline             负责jenkins pipeline部署的项目
    - home1oss/oss-todomvc                      样例项目(引入后需要1.稍加[修改ci.sh脚本](TODOMVC.md)，比如 GIT_REPO_OWNER即该项目拥有者需要修改，并且有个约定todomvc等项目要和oss-internal拥有者一致，还有脚本最后有跳过执行步骤的，直接去掉判断。2.把Dockerfile中的java镜像的registry换成home1oss,或者人工pull一个到docker.registry.internal)   
    - configserver/oss-todomvc-thymeleaf-config     todomvc-thymeleaf配置 **要在gitlab上配置deploy key,公钥在[configserver](https://raw.githubusercontent.com/home1-oss/oss-configserver/master/src/main/resources/deploy_key.pub)中**
    - configserver/oss-todomvc-gateway-config       todomvc-gateway配置 **要在gitlab上配置deploy key,公钥在[configserver](https://raw.githubusercontent.com/home1-oss/oss-configserver/master/src/main/resources/deploy_key.pub)中**
    - configserver/oss-todomvc-app-config           todomvc-app配置 **要在gitlab上配置deploy key,公钥在[configserver](https://raw.githubusercontent.com/home1-oss/oss-configserver/master/src/main/resources/deploy_key.pub)中**
    - configserver/common-config                    所有项目公共配置 **要在gitlab上配置deploy key,公钥在[configserver](https://raw.githubusercontent.com/home1-oss/oss-configserver/master/src/main/resources/deploy_key.pub)中**
    
### jenkins
    
1. [jenkins搭建](JENKINS.md)
2. [ldap配置](JENKINS_LDAP.md)
3. [jenkins slave搭建](JENKINS_SWARM_SLAVE.md)
4. 登录jenkins配置一个名为(注意是ID字段)jenkinsfile的证书访问gitlab，jenkins pipeline 脚本中用到

### sonarquebe

- [sonarquebe搭建](SONARQUEBE.md)

注意： oss-internal的sonar url中的端口要和搭建的sonar服务端口一致

## rancher + k8s

### rancher

必要：**安装合适的docker版本**，准备环节有说明

1. [rancher github](https://github.com/rancher/rancher)
2. 安装注意事项
   - 版本选择 rancher/server:stable and rancher/server:latest
   - 环境问题 主要是docker的版本
   - 安装 非常简单执行 docker run -d --restart=unless-stopped -p 8080:8080 rancher/server:stable
   - 访问8080端口查看

### k8s

1. [图文基于rancher搭建k8s](K8S_PIC.md)
2. [k8s域名后缀定制](MODIFY_K8S_DNS.md) 
3. [k8s实战网上教程，基本是官网翻译，只是版本旧些，注意里面的rc已经被rs取代](http://blog.csdn.net/ztsinghua/article/details/52411483)
4. [基于rancher的k8s实践](RANCHER_K8S_INACTION.md)   
   
### gitlab ci runner 
   
因为项目需要集成测试，所有ci runner部署在k8s中，这样避免了'跨域'访问问题。

- [gitlab-ci-runner k8s环境搭建](GITLAB_CI_RUNNER.md)
   

## 正常开发注意事项   
   
### oss-internal

- k8s配置需更新
- maven_opts_internal.sh里面各个服务和所搭建的环境url一致
- maven_opts_internal.sh可定义集成测试使用的变量

### oss-jenkins-pipeline

- 脚本中默认使用ID为`jenkinsfile`的证书   
- 兼容docker-compose,k8s部署，但是k8s项目文件夹都用-k8s结尾来区分   

## TODO 关于项目todomvc样例项目的k8s部署文档都在 oss-jenkins-pipeline项目中