# sonarqube 服务搭建

## 克隆机器
参见虚机克隆的详细步骤，克隆完毕参照修改DNS解析，在DNS服务器增加sonarqube相关的域名解析

    sonarqube.internal

## 代码检出

    git clone git@github.com:home1-oss/oss-docker.git # 构建postgress数据库服务
    git clone git@github.com:home1-oss/docker-sonarqube.git # 构建sonarqube服务

## 服务构建&启动

### PG数据库服务

    cd oss-docker/postgresql/
    docker-compose build
    docker-compose up -d

    # 创建sonar数据库以及用户
    docker exec -it local-postgresql psql -U postgres -c "CREATE DATABASE sonar;"
    docker exec -it local-postgresql psql -U postgres -c "CREATE USER sonar SUPERUSER PASSWORD 'sonar';"
    docker exec -it local-postgresql psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE sonar TO sonar;"

### sonar服务

    cd docker-sonarqube
    docker-compose build # build之前按需修改定制docker暴露的端口，默认是9000
    docker-compose up -d


## 检查
访问[sonarqube](http://sonarqube.internal/)检查服务是否启动ok

## 参考资料