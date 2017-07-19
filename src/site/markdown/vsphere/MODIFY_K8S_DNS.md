# 修改k8s集群dns后缀

# fork project

    git@github.com:rancher/rancher-catalog.git

# modify dns suffix

    https://github.com/rainleon/rancher-catalog/blob/master/infra-templates/k8s/21/docker-compose.yml.tpl

    #将以下内容
    --cluster-domain=cluster.local
    #修改为
    --cluster-domain=cluster.k8s

# 修改rancher界面上的catalog地址

    {rancher.local}/admin/settings,

    Add catalog，Ex
    https://github.com/rainleon/rancher-catalog.git
    保存即可


# 在env管理界面，Add Template

    选择刚添加的对应catalog，然后后续的env使用这个模板。

