
# oss开发者和用户应该知道的n件事

1. 如何使用源代码

  搭建本地开发环境请一定要参考[CONTRIBUTION文档](./CONTRIBUTION.html)

  维护oss代码需遵守的规则:
  - 我们想要多人愉快地协作, 所以我们使用gitflow, 具体内容请参考 [oss的分支模型](./GITFLOW.html)
  - 我们不想在版本控制上看到多余的 关于格式的diff, 我们想要更好的代码质量, 所以我们强制规定每个人使用同样的 [oss的代码规范](./CODESTYLE.html)
  - 我们 [如何使用oss为项目构建网站](./MVNSITE.html)
  - 当你认为别人的代码有问题, 需要改的时候, 最好先问一下, 要么发邮件, 要么提issue, 总之最好不要直接动手, 因为事情可能不是**你想的那样**, 那么写是有**特别的考虑**.
  - 修改代码的时候一定要多想想对其它地方的影响, 不确定的地方最好找相关的人问清楚.
  - 修改代码的同时不要忘记同步更新文档.
  - 我们付出很多努力才做到代码和环境分离, 我们希望所有参与者一起保持这个风格, 不要在代码里写环境特定的配置.
  - commit代码之前 一定要在本地 build一遍, 确定代码能通过单元测试并成功打包, 然后再commit.

2. 在哪里找到项目文档, 如何维护项目文档

  - 项目文档放在哪里?
  > 每个子项目root下都有一个`README.md`文档, 它的图片素材放在`src/readme`目录.
  > 除了`README.md`之外, 还有一个`src/site/markdown`目录, 这里放`README.md`之外的文档, 图片素材放在`src/site/markdown/images`.

  - 为什么会生成一些文件和目录?
  > `src/site/markdown/README.md`, `src/site/markdown/src/readme`, `src/site/resources`是生成的.
  > `src/site/markdown/README.md`, `src/site/markdown/src/readme`是将外面的`README.md`及其图片素材复制到`src/site/markdown`产生的, 
  因为生成maven网站时只会处理`src/site/markdown`下面的文档, 所以需要把它们复制进来.
  > `src/site/resources/images`是为了解决: maven网站看不到markdown引用的图片. 本地编辑时需要将图片放在相对于文档的`images`目录下, 
  但是maven网站要求图片素材在`src/site/resources`下, 我们只好在生成网站之前把它们复制过去, 这样本地和网站都能看到图片.
  > 需要注意: 不要提交这些生成的文件和目录到版本控制, 我们已经在`.gitignore`文件中忽略了它们.

  - 如何使用同一套文档生成gitbook与maven网站
  > 除了maven网站我们还有一本gitbook, 它们是使用同一套markdown文档生成的, 只不过gitbook的目录更好看, 更便于搜索, 更便于分享到其他设备.
  我们在生成gitbook时会将每个项目中的文档复制到`gitbook工作目录`下, 我们会把项目层次结构以及文档与其图片素材的相对路径也搬过去, 
  并且gitbook与maven网站保持一致, 这样文档中互相引用的URL在gitbook和maven网站中都可以正常工作.

  - 文档内的链接为何使用`DOC.html`而不是`DOC.md`
  > 文档内部链接如果写`DOC.md`则maven网站不正常但gitbook正常, 写`DOC.html`则gitbook与maven网站都正常.
  我们优先保证gitbook和maven网址可用, 没有考虑git服务如gitlab上是否正常, 因为git服务会破坏项目的相对位置关系, 
  引用项目内部文档是可以的但跨出项目就不行, 所以我们无法保证链接在git服务上是正确的.
  > 本篇文档内的链接同样遵循这个规则.
  > 例外是引用`README.html`时, 例如`../oss-lib/README.html`要写成`../oss-lib/`, 因为gitbook
  会把README.md变成index.html, 如果写了`README.html`会产生坏链接.

  - 在gitbook的目录`SUMMARY.md`中要使用`DOC.md`引用文档
  > 同时需要注意`DOC.md`在目录中的标题, 要与文档开篇`#标题`保持一致.

  - 如何维护`site.xml`
  > `site.xml`是maven网站配置文件, 所有`src/site/markdown`下的文档都要在`site.xml`引用才会出现在maven网站中.
  > 注意顶层项目的`site.xml`和子项目的`site.xml`内容有差异.
  > 可以参考我们既有的项目来写`site.xml`.

  - 如果你要修改一篇文档的标题 务必先搜索整个项目, 防止忘记修改引用此文档的地方.

3. 为什么需要设置MAVEN_OPTS等环境变量?

  - 为了代码和环境分离
  > 我们的项目不与特定环境绑死, 这样我们可以非常方便地切换本地环境或公司内部环境, 同时不用担心代码泄露造成泄密.

  - 这里说的环境是什么环境?
  > 构建相关的环境, 即你当前工作的环境, 注意： 不是 应用或服务运行的环境.
  > maven只管构建发布时用到的环境变量, 应用测试等运行时环境变量应通过ci脚本在最外围设置.
  > 集成测试时 spring-boot-maven-plugin 和 maven-failsafe-plugin 会派生进程跑服务和测试, 派生的进程可以访问到我们设置的环境变量.

  - 有哪些环境?
  > 目前我们支持: 本地环境, 公司内部环境 两套环境.

  - 环境里包含哪些内容?
  > nexus服务的地址, docker-registry的地址, checkstyle配置文件的地址, pmd配置文件的地址等.

  － 如何切换环境?
  > 我们通过在运行时设置`MAVEN_OPTS`, 来切换环境.
  > 具体的方法可以参考[CONTRIBUTION](CONTRIBUTION.html)文档.

  - 为什么要在oss父pom中使用maven的profile来设置property默认值.
  > 因为maven在这里有一个坑, 如果在&lt;properties&gt;中定义了属性, 那么只能通过`mvn -Dproperty=value`覆盖它, 写`MAVEN_OPTS="-Dproperty=value"`是无效的.

4. 为何要搭建本地环境

  为了做试验时不影响其他人正常工作.
  为了不与其他人冲突, 比如eureka.
  为了不在公司没有VPN也可以办公, 比如在家办公.
  本地环境比公司环境更快, 搞坏了也不用找运维, 重新启动一下就好.
  总之是为了提高工作效率.

  - 为什么尽可能不使用localhost?
  > 我们使用主机名(hostname), 或域名来标识/区分服务, 因为IP地址可能会变动, 所以不能使用IP地址.
  > localhost本身不能标识服务, 必须结合特定端口才能标识服务, 但受限于docker网络方案, 有时候端口号不是常用端口, 很难区分各个服务.
  > 当不指代某个特定服务时, 比如临时编写的用于本地研究, 测试或演示样例的应用, 我们通常在文档中使用 `127.0.0.1:8080` 来指代这类进程, 而不是 `localhost:8080`.

5. oss预置的环境s

  - 为什么要预置环境?
  > 方便开发人员沟通, 防止不同开发者给同一个环境起不同的名称.
  > 我们需要根据 `生产环境` 和 `非生产环境` 来开启/关闭一些东西, 比如swagger文档.
  > 通过`.env`后缀我们很容易区分哪些spring的profile是环境相关的, 哪些不是.
  > spring的profile在本地使用什么名字都可以, 但如果把配置文件放在configserver上, 会对profile命名有要求, 比如我们目前使用的版本, 
  带`-`的profile是取不到的, 为了避免发生这种非常隐蔽的错误(不会抛异常), 我们事先约定了几个环境.

  - 预置了哪些环境?
  > development.env 开发环境. 如果你使用我们提供的docker-compose.yml启动oss的服务, 就是开发环境.
  如果使用configserver, 那么这个环境对应的配置repo应设置成develop或当前特性分支.
  > it.env 集成测试环境. 跑集成测试时要把你的服务和你依赖的服务都设置成`-Dspring.profiles.active=it.env`.
  如果使用configserver, 那么这个环境对应的配置repo应设置成develop或当前特性分支.
  > staging.env QA测试/预发布/线下测试环境. 我们给大家提供的办公网络可直接访问的eureka和configserver集群即属于staging环境, 
  本地开发时我们建议你使用docker-compose在本地启动开发环境的实例, 多人共用staging环境可能会注册同一服务的多个不同版本(不同特性分支), 
  客户端进行负载均衡轮询访问会出乱子.
  如果使用configserver, 那么这个环境对应的配置repo应设置成develop分支.
  > production.env 生产环境.
  如果使用configserver, 那么这个环境对应的配置repo应设置成master分支.
  
  - 为什么没有`ut.env`即单元测试环境
  > 单元测试不应该启动完整的applicationContext.
  > 单元测试应该使用代码配置bean而不是加载配置文件.

6. 为什么使用docker, 以及如何构建docker镜像

  - 使用docker有多个原因
  > 可以通过Dockerfile把软件安装过程和运行环境变成代码, 受版本控制系统管理, 并且可以自动构建, 保持开发到生产环境的一致性.
  > 可以通过docker-compose使用户非常方便地启动我们的服务.
  > docker可以简化部署和运维, 有助于实现devOps.
  > docker镜像可以继承 (`FROM registry/parentImage:version`), 这样可以使子镜像统一具备一些能力, 
  比如我们的基础java镜像里配置了可选的JMX, 远程调试等功能, 这样java应用可以直接使用这些能力.

  为什么要把`Dockerfile`放到`src/main/resources/docker`下?
  > 我们需要切换环境, 不同环境下的 docker-registry 地址是不同的.
  但是docker和当前的docker-maven-plugin不支持 `FROM ${docker.registry}/imageName:imageTag` 这样的语法.
  我们只好利用docker的resources插件的filter机制, 将 `src/main/resources/docker/Dockerfile` 复制到 `src/main/docker/Dockerfile`
  复制过程中resources插件替换${docker.registry}为当前环境的docker-registry.
  同时我们在.gitignore中忽略了`src/main/docker/Dockerfile`.

  为什么不把`entrypoint.sh`也放到`src/main/resources/docker`下?
  > 因为`entrypoint.sh`是个shell脚本, 变量的表达方式与maven非常相似, 所以很可能在复制过程中发生意外替换, 产生非常隐蔽的错误.
  > shell脚本的写法非常灵活, 通常不需要借助`${docker.registry}`这样的变量.
  > 实在需要使用环境相关的变量可以在启动docker容器时传进去, 这样可以使代码和环境更好地分离.

  为什么我们自己的基于java的服务的Dockerfile都会有一个 `VOLUME /root/data`, 并且在 docker-compose.yml 中挂载这个 volume?
  > 我们目前没有选定一个收集日志的方案, 现存方案都不够理想, 我们暂时需要把日志放到文件系统上.
  有些容器在非生产环境使用h2等内嵌数据库, 需要把数据文件放在文件系统上.
  总之有些文件不随容器升级(删除, 启动新容器)而删除.
  > 我们需要一个地方, 任何操作系统都有这个目录, 而且都有权限写, 这样我们的应用无论运行在容器里还是直接运行在主机上, 无论是开发机还是服务器, 都可以读写.
  我们的选择很有限, 最后选择了用户目录 `${HOME}` 或 `~` 即Java的 `user.home`.
  > 我们在Dockerfile里统一使用 `VOLUME /root/data` 是因为在容器里我们简单地使用了root用户, 如果使用其他用户则使用 `VOLUME /home/用户名/data`.
  > 在 docker-compose.yml 中挂载这个volume 是因为, 如果我们不创建一个命名的volume, 那么docker会创建一个随机的
  很难搞清楚这些随机volume属于哪个容器, 反正目前无法用一条命令解决, 为此我们还专门写了个脚本.
  为了清晰地标识volume, 我们要坚持创建命名的volume, 如果发现存在随机创建了未命名的volume, 应该找到原因, 创建issue, 并且修复这样的bug.

  编写 Dockerfile, entrypoint.sh 和 docker-compose.yml 时应该注意些什么?
  > 要注意Dockerfile中命令的顺序, 把耗时长不易变的放在前面, 耗时短且易变的放在后面, 这样可以缩短重新构建镜像/升级镜像的时间, 可参考oss现有实现.
  > 要注意Dockerfile中的语言区域, 文件编码, 时区等设置, 可参考oss现有实现.
  > 在Dockerfile中执行`apt-get`, `yum install`前尽量将软件源替换成国内或可以高速下载的国外软件源.
  > 在Dockerfile中执行`apt-get`, `yum install`时应将多条命令用 `&&` 拼接成一条, 并在最后清理缓存和临时文件, 这样只会生成一个层, 而且尺寸比较优化.
  > entrypoint.sh应尽量在最后一行 `exec "$@"`, 前面的行都是为它准备参数, 比如: `set -- java ${JAVA_OPTS} -jar *-exec.jar "$@"`,
  这样生成的镜像能直接`docker run --rm -it image-name /bin/bash`启动, 易于调试.
  > entrypoint.sh应使用`exec`启动服务进程, 这样可以把`docker kill`的终止信号传递给服务进程, 实现平稳优雅关闭服务.
  > 写docker-compose.yml时应注意创建命名的volume并挂载Dockerfile中定义的所有volume, 这样不会自动创建未命名的volume, 方便管理.
  > 写docker-compose.yml时不应发明新的环境变量, 并且尽可能地为每个环境变量提供合理的默认值, 这样在本地环境可以不设置任何东西直接启动就能用.
  应尽量使用应用定义的环境变量, 并在相关的地方统一使用同一个环境变量及其默认值.
  比如:
  我们的spring-boot的web应用的`application.yml中`都有一个`server.port: ${SERVER_PORT:8080}`, 意思是如果没有`SERVER_PORT`环境变量就使用默认值`8080`,
  我们在docker-compose.yml中这样写:


        ...
        hostname: ${EUREKA_INSTANCE_HOSTNAME:-servicename.local} # (1)
        ports:
        - "${EUREKA_INSTANCE_NONSECUREPORT:-8081}:${SERVER_PORT:-8080}" # (2)
        environment:
        - EUREKA_INSTANCE_HOSTNAME=${EUREKA_INSTANCE_HOSTNAME:-servicename.local} # (3)
        - EUREKA_INSTANCE_NONSECUREPORT=${EUREKA_INSTANCE_NONSECUREPORT:-8081} # (4)
        - SERVER_PORT=${SERVER_PORT:-8080} # (5)
        ...

  > (1) `servicename`服务在Eureka上注册的主机名, 客户端调用此服务时使用这里配置的地址, 所以这必须是一个客户端DNS可解析的域名或客户端绑定了的/ets/hosts条目.
  > (2) `servicename`服务进程在容器内部监听`SERVER_PORT`端口, 通过docker绑定到容器宿主机的`EUREKA_INSTANCE_NONSECUREPORT`端口, 
  通过局域网访问`servicename`服务时要连接宿主机的`EUREKA_INSTANCE_NONSECUREPORT`端口才能通.
  > (3) 将`EUREKA_INSTANCE_HOSTNAME`环境变量传给容器, 进而传给容器内的`servicename`服务进程, 这样服务向Eureka注册时就会报上这个值.
  > (4) 将`EUREKA_INSTANCE_NONSECUREPORT`环境变量传给容器, 进而传给容器内的`servicename`服务进程, 这样服务向Eureka注册时就会报上这个值.
  > (5) 将`SERVER_PORT`环境变量传给容器, 进而传给容器内的`servicename`服务进程, 它就会监听`SERVER_PORT`指定的端口.
  > 从客户端视角看 (客户端从Eureka上取得`servicename`服务的信息), `servicename`服务在 `EUREKA_INSTANCE_HOSTNAME:EUREKA_INSTANCE_NONSECUREPORT`
  > `EUREKA_INSTANCE_NONSECUREPORT` 默认值是8081, `SERVER_PORT` 默认值是8080, 如果启动docker-compose时不额外设置, 就使用默认值, 
  如果启动docker-compose时设置了环境变量, 所有相关的配置都会变成设置的值.
  > 这样会有一种非常协调的感觉, 不用设置环境, 使用默认值就可以正确运行, 
  一旦设置一个变量, 相关的地方全变过去, 而且一定可以正确运行.
  > 不应该在docker-compose.yml中发明`SERVICENAME_EUREKA_INSTANCE_NONSECUREPORT`这种环境变量.
  > 不用担心在一台机器上运行多个docker容器时环境变量会冲突, 因为只要你不把环境变量写到/etc/profile或.bash_profile中就不会冲突,
  因为正常情况下无论我们ssh到主机上执行命令还是通过jenkins做类似的事情时, 我们都是在独立的session中定义环境变量, 这些环境变量出不了你的session.
  > 我们在项目中提供一个默认的`docker-compose.yml`文件, 它可以直接`docker-compose up -d`启动, 无需任何配置, 这样搭建本地开发环境或局域网测试环境很方便,
  我们要求所有`oss提供的服务`都这样做.
  > 在部署环境(相关代码在单独的git repository)对于每个服务我们有另一个`docker-compose.yml`文件, 
  为了发布和部署分离以及代码和环境分离, 在没有更好的解决办法前, 我们只能选择复制一个`docker-compose.yml`过去.
  原则上我们要求在部署的git repository中的`docker-compose.yml`与在项目代码中的一摸一样, 环境变量通过环境变量文件赋值.
  如果确实需要不一样, 我们要么重构代码做到一摸一样, 要么短暂允许不一致但也要保持行的一一对应, 即两个文件每行内容都互相对应,
  只不过在其中一个文件中可能会注释掉, 或是空行, 在另一边有值, 这样我们可以非常清晰地看到diff, 防止维护时犯错误, 凸显出不同环境的差异.
  > 我们要求在`docker-compose.yml`中`environment:`, `ports:`等有列表的地方, 列表内容按字典序排列.
  > 如果你发现违例的代码, 应该通知项目的维护者, 提issue提醒他, 或打个招呼自己改过来.

  TODO 为什么有些Dockerfile只是简单地重新tag官方镜像

7. 为什么使用jenkins pipeline

  > 降低对运维的人工依赖, 提高效率.
  > 将环境相关, 部署相关的代码从项目中移除, 集中放到这里.
  > 将环境和部署过程变成代码, 做到历史可追溯, 通过git服务控制权限.
  > jenkins服务可以做到无配置或最小最简配置, 可快速重建环境.

8. 为什么混用gitlab-ci 和 jenkins

  > 由于历史原因, 我们在构建/发布时使用了gitlab-ci, 在部署时使用了jenkins.
  > 我们的项目做到了发布和部署分离, 它们是两个完全独立的过程, 所以既可以用同样的工具进行, 也可以用不同的工具.
  > 在使用过程中我们发现gitlab-ci存在一些难以克服的弱点, 比如无法优雅地分发配置文件到runner上.
  > 所以我们最终会将构建/发布和部署都迁移到jenkins上, 我们仍会保持发布和部署分离.

9. 为什么要配置spring-boot-maven-plugin 设置classifier为exec, 并且设置attach为false

  如果不设置classifier会怎样?
  > spring-boot-maven-plugin会将maven打出的原始*.jar包替换成*.jar.original, 用自己repackage过的包含全部运行时依赖的大jar包顶替上去.
  > maven-failsafe-plugin只能使用maven打出的原始*.jar, spring-boot-maven-plugin的构建产物会导致它异常退出无法运行集成测试.

  如果不设置attach为false会怎样?
  > 我们的maven私服nexus通常不接受包含全部运行时依赖的大jar包, 会报出`413 Request Entity Too Large`错误.
  > nexus私服的磁盘空间会非常快速地被消耗掉.

  为什么设置classifier为exec?
  > spring-boot-maven-plugin的官方文档是这样写的, 我们认为这个名字不错.
  > 有一个-exec可以很好地区分可执行jar包, 原始jar包, 源码和javadoc包, Dockerfile和entrypoint.sh都会变得更好写.

10. maven插件的执行顺序很重要, 如何避免破坏它们

  > 看官方的`Maven – Introduction to the Build Lifecycle`文档, 并记住构建过程中的各个阶段(`phase`), 它们的先后顺序.
  > 所有maven插件的运行(`execution`)都是绑定到阶段(`phase`)上的, 每个`execution`可以包含一个或多个目标(`goal`).
  > 我们平时执行`maven clean install`是告诉maven执行这些阶段绑定的所有插件的`execution`.
  > 如果多个插件绑定到同一个阶段上, 那么它们在&lt;plugins&gt;中的顺序就是它们的执行顺序.
  > 所以maven插件的顺序是不可以随便写的, 最好按照它们执行的顺序排列好.
  > 可以参考我们的maven骨架项目`oss-archetype`.

11. 为什么要写测试

  > 如果没有自动化测试, 那每次改动之后都需要手动回归, 否则就有可能引入新缺陷, 非常低效, 自动化测试可以自动回归, 防止软件被无意损坏.
  > 如果没有自动化测试, 那每次升级一个依赖你都需要掂量掂量, 升级了也需要手动回归, 这会阻碍你使用新技术, 技术栈越来越旧最终失去竞争力.
  > 如果没有自动化测试, 谁说你的接口有问题你都得查半天.
  > 不好测的软件肯定是结构有问题, 不写测试就永远写不出好代码.
  > 总之不写测试一时爽, 但其实是自掘坟墓, 害人害己.
  > 虽然不写测试有这么多坏处, 写测试有这么多好处, 但不要过度测试, 否则也会影响效率, 
  至于什么是过度测试, 如果在没有技术问题的情况下, 大多数人都无法忍受测试运行的速度了, 那应该就是过度了.

12. 如何维护配置文件

  > 这里提到的配置文件主要指spring-boot的`application.yml`和spring-cloud的`bootstrap.yml`
  > 维护`application.yml`时要注意我们把配置文件托管到configserver上, 那里有一套所有应用共享的公共配置.
  虽然你可以在自己项目的`application.yml`中覆盖公共配置, 但在覆盖公共配置里已有的配置项时一定要想清楚这样做的后果.
  因为公共配置里有些东西是为大家提供方便的, 比如各环境下mq等公共服务的地址等配置, 如果你的环境特殊, 可以安全地覆盖.
  还有另外一部分是有意要集中管控的, 比如服务间通信使用的key等配置, 覆盖了会出问题.
  > 配置文件应该提供一套本地(local)环境的默认配置, 这样任何人拿到代码无需配置就能直接启动, 这是必须的, 不是可选项,
  当然你可以要求用户先启动某个依赖的服务或在启动服务前绑定/etc/hosts, 这是可以的.
  > 配置项的默认值应该可以被环境变量覆盖, 这样在各个操作系统甚至docker环境下都无需修改配置文件就能修改配置, 
  当然永远不需修改的配置项不必这么做.
  > 用户除了使用环境变量, 还可能使用VM参数, 比如: `-Dserver.port=8080` 来覆盖配置项, 在写配置文件的时候要考虑到这种可能性.
  例如, 在公共配置里有这么一段:


        eureka:
          instance:
            metadataMap:
              management.port: ${management.port:${MANAGEMENT_PORT:${server.port:${SERVER_PORT:8080}}}}
  
  > 它的作用是告诉Eureka, 我们的服务的管理端口, 这样admin服务可以通过Eureka找到我们的服务并提供管理界面.
  作为公共配置, 需要处理所有可能的情况, 如果用户设置了`-Dmanagement.port=8000`, 那我们就要使用这个值,
  如果用户没有设置`-Dmanagement.port`, 我们需要继续看用户是否设置了`MANAGEMENT_PORT`环境变量, 
  如果仍然没有设置, 那么管理端口与服务端口就共用同一个端口, 即`server.port`, 
  如果用户没有设置`-Dserver.port`, 我们还要看看他是否设置了`SERVER_PORT`环境变量, 
  如果用户什么都没有设置, 那么使用默认值8080.
  同时我们还需要一个`server.port`的默认设置与这里保持一致, 这样才能保证我们的配置总是正常可工作的.
  `server.port`应该像下面这样:


        server:
          port: ${SERVER_PORT:8080}

  > 看到这里大家应该明白, 配置项有可能不是独立的, 而是会互相影响, 这时我们需要从总体的角度考虑它们之间的关系, 是否协调.
  > 从具体技术角度看, 这样写是因为在spring-boot环境下, 使用`-Dserver.port`这种方式跟直接在配置文件里写死它是等效的, 它的优先级最高, 其次才是环境变量.
  > 环境变量命名规则, 环境变量应该与配置项名称严格对应, 但全部字符大写, 
  在配置项里面的`.`或`:`在环境变量中应该使用`_`, 在配置项里面使用`-`或驼峰的在环境变量中应该连起来写.
  例如: 
  `server.port`对应`SERVER_PORT`, 
  `spring.h2.console.web-allow-others`或`spring.h2.console.webAllowOthers`对应`SPRING_H2_CONSOLE_WEBALLOWOTHERS`
  
  > 最后要注意不要自己发明配置项, 应尽量使用spring-boot和spring-cloud已有的配置项, 定义配置前先仔细查好文档.
  这样可以降低用户的学习成本, 也减少维护文档的工作量.

13. 如何维护pom.xml 和 build.gradle

14. oss的4种应用类型是什么

  为什么要定义这些应用类型?
  > 这些应用类型最早是在编写lib-errorhandle时定义的.
  因为我们面临一个难题: 不是所有客户端都发送并且发送正确的 HTTP `Accept` header.
  但我们要尽力为用户返回一个合理的错误信息或定向到错误页.
  > 所以我们需要用户给我们一点提示, 告诉我们应用是什么类型的, 这样我们就很容易排除一些不可能的选项, 更准确地处理错误信息.
  比如`TEMPLATE`是纯模板应用, 那么它永远不会返回一个JSON或XML错误信息, 只会用到错误页(error page).
  再比如`RESTFUL`应用, 它永远不会用到错误页, 只会返回JSON或XML, 即使我仍然可能不知道你要什么(如果没有`Accept` header)
  但我至少不会把你定向到错误页, 并且可以在这种情况提供一个默认设置, 这样行为总是符合预期的.
  比较糟糕的情况是`MIXED`应用, 这样的应用既有RESTful接口又在部分页面上使用了模板技术, 这时我们只能依赖 HTTP header
  来进行内容协商, 由你来告诉我们要什么, 或是我们尽量猜, 但有可能猜错.
  > 后来我们在编写lib-security时发现 spring-security的很多处理逻辑都在filter上, filter里用不到spring-webmvc为
  controller们准备的强大的基础设施, 如果发生认证或授权错误, 我们需要手动调用lib-errorhandle来提供一致的错误处理体验.
  > lib-security在配置spring-security时也会根据应用类型来进行取舍, 比如`RESOURCE`类型的应用和`RESTFUL`类型的应用, 
  对于lib-errorhandle来说是一样的, 都是只有RESTful接口的应用, 不使用模板技术, 都不会有错误页.
  但对于lib-security来说`RESOURCE`类型是纯后端服务, 可以理解为没有前端界面, 只暴露RPC接口, 这样它没必要配置Basic Auth和表单登陆.
  `RESTFUL`类型则有前端界面跟它交互, 需要保留Basic Auth和表单登陆.
  > 所以这些应用类型对lib-errorhandle和lib-security都有意义.


<table>
<tr>
    <td>类型</td>
    <td>含义</td>
    <td>对于lib-security的含义</td>
    <td>对于lib-errorhandle的含义</td>
</tr>
<tr>
    <td>RESOURCE</td>
    <td>
        纯后台服务, 与前端无交互, 只接受RPC调用, 只有RESTful接口, 不使用模板技术
    </td>
    <td>
        只提供基于Header的Token的认证, 不提供基于Cookie的Token认证, Basic Auth和登陆表单认证
    </td>
    <td>
        只返回JSON或XML错误信息, 没有错误页
    </td>
</tr>
    <td>RESTFUL</td>
    <td>
        RESTful应用, 与前端有交互, 接受前端调用也可以接受RPC调用, 只有RESTful接口, 不使用模板技术
    </td>
    <td>
        除了提供基于Header和Cookie的Token认证, 还提供Basic Auth和登陆表单认证
    </td>
    <td>
        只返回JSON或XML错误信息, 没有错误页
    </td>
<tr>
    <td>TEMPLATE</td>
    <td>
        前端应用, 使用模板技术实现, 无RESTful接口
    </td>
    <td>
        提供基于Cookie的Token认证, 登陆表单认证, 不提供基于Header的Token认证和Basic Auth
    </td>
    <td>
        只有错误页, 不返回JSON或XML错误信息
    </td>
</tr>
<tr>
    <td>MIXED</td>
    <td>
        前端应用, 既使用模板技术又有一部分RESTful接口
    </td>
    <td>
        提供基于Header和Cookie的Token认证, Basic Auth, 登陆表单认证
    </td>
    <td>
        由内容协商决定返回JSON/XML错误信息或错误页
    </td>
</tr>
</table>

15. 如何使我们的项目健康成长, 使它成为所有参与者的资产而不是需要被动完成的任务和技术债务

TODO

16. 最后 我们希望所有的oss开发者都有一点代码洁癖

  > 不要容忍不好的代码, 如果现在没时间, 记下来, 提issue, 一有时间就把它改过来, 或者寻求队友帮助.
  > 不要容忍不合理的设计, 如果现在没时间, 记下来, 提issue, 一有时间就把它改过来, 或者寻求队友帮助.
  > 如果实在拿不准怎么做, 记得叫上大家一起商量讨论.

TODO fork项目 git-flow问题
