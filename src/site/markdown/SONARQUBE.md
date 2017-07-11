
# 使用sonarqube评估代码质量

  本文帮助你搭建简易的本地sonarqube实例.

## 启动docker容器

  进入 `docker-sonarqube`
  启动 postgresql


        (cd postgresql; docker-compose up -d)

  创建数据库和用户


        docker exec -it postgresql.local psql -U postgres -c "CREATE DATABASE sonar;"
        docker exec -it postgresql.local psql -U postgres -c "CREATE USER sonar SUPERUSER PASSWORD 'sonar';"
        docker exec -it postgresql.local psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE sonar TO sonar;"

  启动 sonarqube


        (cd sonarqube; docker-compose up -d)


## 编辑 /etc/hosts 或与其等效的文件, 加入以下内容


        127.0.0.1 postgresql.local
        127.0.0.1 sonarqube.local

  浏览 `http://admin:admin@sonarqube.local:9000` 测试服务是否正常启动.

## 运行方式1

  执行 `mvn sonar:sonar -Dsonar.host.url=http://sonarqube.local:9000`
  
  `mvn --batch-mode verify sonar:sonar -Dmaven.test.failure.ignore=true -Dsonar.host.url=http://sonarqube.local:9000`


## 运行方式2

  编辑 ~/.m2/settings.xml 或与其等效的文件, 加入以下内容


        <pluginGroups>
            <pluginGroup>org.sonarsource.scanner.maven</pluginGroup>
        </pluginGroups>
        <profiles>
            <profile>
                <id>sonarqube.local</id>
                <activation>
                    <activeByDefault>true</activeByDefault>
                </activation>
                <properties>
                    <!-- Optional URL to server. Default value is http://localhost:9000 -->
                    <sonar.host.url>http://sonarqube.local:9000</sonar.host.url>
                    <!--sonar.jdbc.url>jdbc:h2:tcp://sonarqube.local/sonar</sonar.jdbc.url>
                    <sonar.jdbc.url>jdbc:postgresql://postgresql.local:5432/sonar</sonar.jdbc.url-->
                </properties>
            </profile>
            ....
        </profiles>

  执行 `mvn sonar:sonar`

## 清理数据


        docker volume ls | grep sonarqube  | awk '{print $2}' | xargs docker volume rm
        docker volume ls | grep postgresql | awk '{print $2}' | xargs docker volume rm

## pre commit check

http://docs.sonarqube.org/display/SONAR/Local+and+Branch+Analysis

TODO

## Breaker

https://github.com/sgoertzen/sonar-break-maven-plugin

TODO

## 与gitlab整合

https://gitlab.talanlabs.com/gabriel-allaigre/sonar-gitlab-plugin

TODO
