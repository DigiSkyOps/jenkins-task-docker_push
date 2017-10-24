# 插件名称 

docker_push

# 功能说明

用于推送镜像

# 参数说明

| 参数名称 | 类型 | 默认值 | 是否必须 | 含义 |
|---|---|---|---|---|
| docker.push.image | string | NULL | **必须** | 需要推送镜像名称 |
| docker.push.registry | string | NULL | **必须** | 镜像仓库名称 |
| docker.push.username | string | NULL | **必须** | 镜像仓库登录用户 |
| docker.push.password | string | NULL | **必须** | 镜像仓库登录密码 |
| docker.push.email | string | NULL | **必须** | 镜像仓库登录邮箱 |


# 配置使用样例

```yml
stages:
- name: docker_push
  tasks:
    - task.id: docker_push
      docker.push.image: hub.digi-sky.com/hello/world:1.0.0
      docker.push.registry hub.digi-sky.com
      docker.push.username: admin
      docker.push.password: admin123
      docker.push.email: admin@localhost
```
