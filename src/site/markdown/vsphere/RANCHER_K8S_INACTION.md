
# 基于Rancher的k8s实践

## 集群搭建

#### 操作步骤

 1. `Manage Environments`页面，Add Environment，选择kubernetes的Environment Template，输入名称，如k8s，完成提交。
 2. 设置k8s为默认激活，并切换到k8s环境。
 3. 进入`INFRASTRUCTURE->Hosts` 管理，添加Rancher的主机到k8s环境，k8s会自动部署相关的实例在新的主机。
 3. k8s 集群部署完毕后，页面会出现`KUBERNETES`的tab入口，UI会出现kubernetes UI的入口。
 4. 进入CLI的tab标签页，根据引导，生成`~/.kube/config`文件放到本地对应目录，本地安装kubectl后便可以通过命令行访问k8s集群。

#### 实践问题

- rancher界面请不要切换到中文，否则k8s的dashboard无法进入。
- pod和pod之间的通信，可以直接使用service的名字来作为域名互相调用，不需要ip [nfs挂载除外]
- 初始化

#### NOTE

- rancherOS默认的console安装软件比较费劲，建议切换到centos或者ubuntu，操作如下：
    sudo ros console switch centos 切换到centOS Console
  切换到centos后，个别命令需要手工单独安装。

-------

# Kubernetes相关


## 核心概念
- Node 机器节点，可以简单理解为物理机器
- Pod 最小单元，包含一个或者多个container
- Lable & Selector 标签，为资源制定标签，再定义选择器来进行过滤筛选
- Annotations 扩展 label 提供更丰富的'标签'功能
- RC（Replication Controller） Pod replica管理器，确保任何时候都运行指定数量的pod副本
- Replica Sets 是下一代的Replication Controller
- Service 【ClusterIp、NodePort、LoadBalancer】负责负载均衡或者对外暴露服务，只支持4层负载均衡，NodePort需要额外的负载均衡器
- Ingress [Kubernetes 1.2 新功能介绍：Ingress 原理及实例](http://www.dockerinfo.net/1132.html)
- Volume 卷，存储卷
- Namespace 命名空间用来实现多租户隔离
- Annotation 注解，类似于标签，用来定义原生的k8s的属性，
- Deployment enables declarative updates for Pods and ReplicaSets.
- Daemon Sets 守护进程，可以在每个节点上运行来时刻监控任务，典型应用如：存储，日志采集，性能监控等其他
- Secrets 敏感数据的对象，存储密码，令牌，或密钥等。
- ConfigMap 配置环境变量等 

## 组件
- API Server
    > 提供了资源对象的唯一操作入口，其他所有的组件都必须通过它提供的API来操作资源对象。它以RESTful风格的API对外提供接口。所有Kubernetes资源对象的生命周期维护都是通过调用API Server的接口来完成，例如，用户通过kubectl创建一个Pod，即是通过调用API Server的接口创建一个Pod对象，并储存在ETCD集群中
- Controller Manager
    > 集群内部的管理控制中心，主要目的是实现Kubernetes集群的故障检测和自动恢复等工作。它包含两个核心组件：Node Controller和Replication Controller。其中Node Controller负责计算节点的加入和退出，可以通过Node Controller实现计算节点的扩容和缩容。Replication Controller用于Kubernetes资源对象RC的管理，应用的扩容、缩容以及滚动升级都是有Replication Controller来实现
- Scheduler
    > 集群中的调度器，负责Pod在集群的中的调度和分配
- Kubelet
    > 负责本Node节点上的Pod的创建、修改、监控、删除等Pod的全生命周期管理，Kubelet实时向API Server发送所在计算节点（Node）的信息。
- Proxy
    > 实现Service的抽象，为一组Pod抽象的服务（Service）提供统一接口并提供负载均衡功能。

## 原理图
![](media/images/14894837761208.jpg)
![](media/images/14894838806795.jpg)

#### Master
- apiserver：作为kubernetes系统的入口，封装了核心对象的增删改查操作，以RESTFul接口方式提供给外部客户和内部组件调用。它维护的REST对象将持久化到etcd（一个分布式强一致性的key/value存储）。

- scheduler：负责集群的资源调度，为新建的Pod分配机器。这部分工作分出来变成一个组件，意味着可以很方便地替换成其他的调度器。

- controller-manager：负责执行各种控制器，目前有两类：
    + endpoint-controller：定期关联service和Pod(关联信息由endpoint对象维护)，保证service到Pod的映射总是最新的。
    + replication-controller：定期关联replicationController和Pod，保证replicationController定义的复制数量与实际运行Pod的数量总是一致的。
#### Slave
- kubelet：负责管控docker容器，如启动/停止、监控运行状态等。它会定期从etcd获取分配到本机的Pod，并根据Pod信息启动或停止相应的容器。同时，它也会接收apiserver的HTTP请求，汇报Pod的运行状态。

- proxy：负责为Pod提供代理。它会定期从etcd获取所有的service，并根据service信息创建代理。当某个客户Pod要访问其他Pod时，访问请求会经过本机proxy做转发。

## 资源相关

## 存储-Volume
### 持久卷PV
> 通常我们把存储做成集群，对外表现为一个网络存储，持久卷(PV)是这个资源中的一个片段，就像node和cluster的关系。PV是跟Volume一样是卷插件【详见kubernetes Volume概念】，但其生命周期不依赖任何单个的pod，底层存储实现可以是NFS，iSCSI，云存储等，都通过API对象对外暴露，对用户透明。



### 实践问题
- nexus的 ../sonatype-work/nexus3 目录会软连接到/nexus-data,当/nexus-data配置了nfs，会出现无法启动的问题，另外官方不推荐使用nfs，会导致不可预知的问题。
- nfs服务端export的目录权限需要考虑，否则会导致应用无法读写文件,默认对root用户有效，非root用户会出问题
- pod和pod之间的通信，可以直接使用service的名字来作为域名互相调用，不需要ip
- 初始化卷的操作可以通过`annotations`的 `pod.beta.kubernetes.io/init-containers:`来实现
- 目前nexus3和sonar都使用的是emptyDir的volume，nfs存储卷无法读取。



## 参考资料
- [User Guide](https://kubernetes.io/docs/user-guide/environment-guide/)
- [Kubernetes技术分析之存储](http://www.open-open.com/lib/view/open1438593641817.html)
- [kubernetes中的服务发现与负载均衡](http://feisky.xyz/2016/09/11/Kubernetes%E4%B8%AD%E7%9A%84%E6%9C%8D%E5%8A%A1%E5%8F%91%E7%8E%B0%E4%B8%8E%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1/)
- [Kubernetes 1.2 新功能介绍：Deployment](http://www.dockerinfo.net/1128.html)
- [DockerInfo官网的k8s系列文章](http://www.dockerinfo.net/kubernetes)
- [Kubernetes架构设计与核心原理](http://www.dockerinfo.net/1048.html)

