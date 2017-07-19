# CentOS 7 下使用 bind 搭建 DNS 服务器

> Linux系统中的DNS服务器的名字叫bind，本文介绍CentOS7下，通过bind的安装以及配置来搭建DNS服务器。

<!-- vim-markdown-toc GFM -->
* [环境](#环境)
* [安装](#安装)
* [配置](#配置)
  * [配置文件说明](#配置文件说明)
  * [增加域名](#增加域名)
* [验证测试](#验证测试)
  * [本地测试](#本地测试)
  * [配置允许远端查询](#配置允许远端查询)
  * [配置上游DNS解析](#配置上游dns解析)
* [配置文件说明](#配置文件说明-1)
* [References](#references)

<!-- vim-markdown-toc -->

## 环境

环境 | 说明
---: | :---:
操作系统 | CentOS 7.3.1611
DNS服务器IP | 10.xxx.xxx.xx

## 安装

1. 安装bind 

        yum install bind
    
2. 启动服务，并设置开机启动：

        systemctl start named
        systemctl enable named
    
## 配置

### 配置文件说明

安装后便有个入口配置文件/etc/named.conf，可以配置如下内容：

+ 可以include其他配置文件
+ 设置不同的域的配置文件.

/etc/named.conf 的配置片段，指定了不同的zone所对应的配置文件：


    logging {
        channel default_debug {
            file "data/named.run";
            severity dynamic;
        }
    };
    
    zone "." IN {
        type hint;
        file "named.ca";
    };


### 增加域名

如果要增加internal的域，从而使用a.internal、b.internal等域名，则需要主要进行两步：（1）配置named.conf（2）配置internal的配置文件

1. 在 `/etc/named.conf` 增加域，增加如下配置


        zone "internal" IN {
            type master;
            file "/var/named/internal";
        };


> 上面示例中增加了internal域，并指定了该域的配置文件位置file在`/var/named/internal`。当然的file值也可以换成其他值。

2. 配置/var/named/internal。这个文件可以copy其他已有的文件（例如/var/named/named.empty），然后进行修改(注意权限)。修改成如下内容：

```
$ cat /var/named/internal 

$TTL 3H
@	IN SOA	@ rname.invalid. (
					0	; serial
					1D	; refresh
					1H	; retry
					1W	; expire
					3H )	; minimum
	NS	@
	A	127.0.0.1
	AAAA	::1

k8s     IN  A   10.xxx.xxx.90 
gitlab  IN  A   10.xxx.xxx.60
jenkins IN  A   10.xxx.xxx.62
```

如果要继续增加其他域名，在上面继续按照相同的方式追加即可

3. 重启named服务

        systemctl restart named

## 验证测试
### 本地测试

进行测试前，需要设置本机的dns服务器。编辑/etc/resolv.conf，修改文件为如下内容：

    nameserver 127.0.0.1     #不要写成其他

在DNS服务器本地测试：`nslookup jenkins.internal` 如果能解析到，则说明域名服务器以及域名配置成功

### 配置允许远端查询

在另外一个主机上（如Windows PC）上配置DNS服务器为DNS服务器地址（本例子中为：10.106.146.85），执行nslookup jenkins.internal。可以发现无法解析。
配置文件/etc/named.conf需要进行如下修改

- 将 `listen-on port 53 { 127.0.0.1; };` 修改为 `listen-on port 53 { any; };`
- 将 `allow-query { localhost; };` 修改为 `allow-query { any; };`
- 将 `dnssec-enable yes;` 修改为 `dnssec-enable no; `
- 将 `dnssec-validation yes;` 修改为 `dnssec-validation no;`

重启named服务

    systemctl restart named

再一次远端测试，成功！

### 配置上游DNS解析(***重要***)

一般情况下，自搭建的服务器都只解析自己的域名，其他域名则由正式的DNS服务器解析，这里需要进行一下配置

比如我们把其他域名的解析交给阿里云的服务器，可以在配置文件/etc/named.conf，进行如下修改


    forwarders { xxx.x.x.5;xxx.x.x.6;};  


**配置完成!**

## 配置文件说明


    $ vi named.conf

    options { //服务器的全局配置选项及一些默认设置
        listen-on port 53 { any; }; //监听端口，也可写为 { 127.0.0.1; 192.168.139.46; }
        listen-on-v6 port 53 { ::1; }; //对ip6支持
        directory       "/var/named";  //区域文件存储目录
        dump-file       "/var/named/data/cache_dump.db"; //dump cach的目录directory
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
    
        pid-file        "/var/run/named/named.pid"; //存着named的pid
        forwarders     { 168.95.1.1; xxx.xxx.xx.xxx; }; // 如果域名服务器无法解析时，将请求交由168.95.1.1; xxx.xxx.xx.xx来解析
        allow-query    { any; };   //指定允许进行查询的主机，当然是要所有的电脑都可以查啦
        allow-transfer { none; }; //指定允许接受区域传送请求的主机，说明白一点就是辅dns定义，比如辅dns的ip是192.168.139.5，那么可以这样定义{ 192.168.139.5; }，要不然主辅dns不能同步，当然，{}里的也可以用下面提到的acl。
        // those options should be used carefully because they disable port
        // randomization
        // query-source    port 53;     
        // query-source-v6 port 53;
    };
    logging { //指定服务器日志记录的内容和日志信息来源
        channel default_debug {
            file "data/named.run";
            severity dynamic;
        };
    };
    // 这里定义一个acl列表
    acl "acl1" {
        192.168.139.0/200; 192.168.1.0/200 
    };
    
    view localhost_resolver { //定义一个视图
        match-clients      { any; }; //查询者的源地址，any表示localhost_resolver视图对任何主机开放，如果写成{ acl1; }，那么就只有acl1表里的ip可以递归查询了
        match-destinations { any; }; //查询者的目标地址，这里也可以写成{ localhost; acl1; }
        recursion yes;  //设置进行递归查询
        include "/etc/named.rfc1912.zones"; //包含文件，这里也就是载入/etc/named.rfc1912.zones
    };



## References
1. [DNS服务器（Centos 7）：bind安装&配置](http://blog.csdn.net/K_Zombie/article/details/50593743)

