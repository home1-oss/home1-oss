# gitlab ci runner 环境搭建

## 环境准备

### ci runner中需要使用docker环境

因为有从容器内部访问外部 docker service 的需求，需要修改宿主机的/var/run/docker.sock文件访问权限.

    sudo chmod a+rw /var/run/docker.sock
    
上面的命令需要在所有的k8s节点执行一遍    

### maven的settings-security.xml 文件相关

ci中使用到该文件，目前是通过挂载的形式使用。

- (**已废弃**)若使用现在这样的本地挂载方式，则需要在所有的k8s节点执行

      mkdir -p /root/gitlab-runner/home
      mkdir -p /root/gitlab-runner/etc
      将oss-internal项目中的(src/main/maven目录中)settings-security.xml文件放到/root/gitlab-runner/home/.m2/中 

- 修改挂载方式为nfs方式的话，只需做类似上面操作一次。
- 修改ci脚本，从脚本中下载

### 获取git_service_token

GIT_SERVICE_TOKEN: 访问git服务上私有的项目需要用到用户的认证/授权token，需要在启动镜像的时候export指定，获取token方法：

- 方法1: 登录git服务, 例如gitlab: 进入 Profile Settings->Account->Private Token,获取token
- 方法2: 命令行, 例如gitlab: curl --request POST "${GIT_SERVICE}/api/v3/session?login={邮箱}&password={密码}"


### 克隆项目

- 克隆oss-gitlab项目 `git clone git@github.com:home1-oss/docker-gitlab.git`


## 安装

### k8s部署

1. 进入 `gitlab-runner/k8s/` 目录

       gitlab_service_token: 将gitlab_service_token进行base64编码操作后，配置到runner-secret.yaml中

2. 部署k8s服务

       kubectl create -f *
    
3. 查看gitlab-runner的pod
   
       kubectl get po
4. 进入该pod 
  
       kubectl exec -it gitlab-runner-xxxx /bin/bash
5. 权限设置 
       
       chown -R gitlab-runner:gitlab-runner /home/gitlab-runner
6. 注册操作
   
       kubectl exec -it gitlab-runner-xxxx  gitlab-runner register


       Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com )
       ${INTERNAL_GIT_SERVICE}/ci      ##注意2
        
       Please enter the gitlab-ci token for this runner
       xxx(从 gitlab runner 页面里找)
        
       Please enter the gitlab-ci description for this runner
       oss-gitlab-runner-${ip}
        
       INFO[0034] fcf5c619 Registering runner... succeeded
       Please enter the executor: shell, docker, docker-ssh, ssh?
       shell


7 安装完成，验证
   
kubectl exec -it gitlab-runner-1749966091-5p1nx  gitlab-runner register


   
# 注意 
1. gitlab-runner要注意和gitlab版本对应。
2. gitlab-runner注册url不能使用域名+端口的形式，所有要么gitlab服务直接绑80端口，要么配置nginx   

#### 补充

>
ERROR: Uploading artifacts to coordinator... too large archive  id=116 responseStatus=413 Request En

https://gitlab.com/gitlab-org/gitlab-ce/issues/20612
![](media/images/git-runner-error.png)