
# 如何使用oss为项目构建网站

构建网站是为了更方便地了解工程的当前状态, 网站发布发生在软件包构建和发布之后.
用户可以通过网站上的文档了解软件功能和使用方法, 开发者可以通过网站上的报告及时了解工程质量.

网站包含的主要报告有:  

- JaCoCo     -- 测试覆盖度  
- Coverage   -- 测试覆盖度
- FindBugs   -- bug探测
- JDepend    -- 软件包合理性
- Tag List   -- TODO FIXME 列表
- Checkstyle -- 代码风格
- Dependency Analysis -- 依赖分析
- JavaDocs   -- 带UML图的javadoc
- PMD        -- PMD代码检查
- Surefire   -- 测试结果

#### 构建发布项目网站

构建完整site并发布到公司内部仓库
`mvn -[U] -s ~/.m2/settings.xml -Dinfrastructure=internal -Dsite=true -Dsite.path=<网站路径> clean package site site:stage site:stage-deploy`

构建完整site并发布到本地本地仓库
`mvn [-U] -s ~/.m2/settings.xml -Dinfrastructure=local -Dsite=true -Dsite.path=<网站路径> clean package site site:stage site:stage-deploy`

离线状态仅构建顶层site
`mvn -N -o site`

#### 注意:构建带UML的Javadoc需要安装GraphViz

  如果未正确安装 会发生错误: java.io.IOException: Cannot run program "dot": error=2, 没有那个文件或目录

    # Mac OSX
    brew install graphviz
    
    # CentOS 7.x
    curl -o /etc/yum.repos.d/graphviz-rhel.repo http://www.graphviz.org/graphviz-rhel.repo
    # Just edit the snapshot section so that “enabled=1”, and correspondingly disable the stable section.
    yum list available 'graphviz*'
    yum install 'graphviz*'

#### 发布Site到Github

* see: [site plugin does not support multi-module site deployment](https://github.com/github/maven-plugins/issues/22)

如果使用github oauth token, token 需要具备 repo, user 两组 权限.
同时还要注意github账户必须设置了 username, 组织机构必须设置 Organization display name, 其值应与url路径一致, 
否则会发生 Error creating blob: Not Found (404) 这样的错误.
* see: [Error retrieving user info: Not Found (404)](https://github.com/github/maven-plugins/issues/100)

有的问题可能由API rate limit引起, 可以查询它.

    curl -H "Authorization: token ${GITHUB_INFRASTRUCTURE_CONF_GIT_TOKEN}" https://api.github.com/rate_limit

复位时间可以查询

    curl -I https://api.github.com/orgs/home-oss

X-RateLimit-Reset 值即复位时间
