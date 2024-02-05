# Deployment Chart更新内容

## 1.4.0

- 优化探针：
    - ~~更新后端保活策略（单服务：保活http, 集群：保活tcp+就绪http）,我们项目以单服务为主~~

      更新后端保活策略（保活tcp+就绪http）

    - ~~新增前端保活策略（单服务：保活http, 集群：保活tcp+就绪http）,我们项目以单服务为主~~
      
      新增前端保活策略（保活tcp+就绪http）
      
      nginx_status接口获取nginx连接数等信息，启动探针15秒，存活探针1分钟4次
- 链路追踪：增加skywalking，使用hostPath映射agent.jar（ansible配合分发）
- JVM使用容器内存的最大百分比调整：70 --> 75
- 扩容：最大扩容数由5-->3
- 启动探针：由于添加链路追踪，启动探针时间调整：100秒-->150秒
- 增加可配置参数
     - 重启策略
     - 历史版本数量
     - 使用主机网络
     - 容忍
     - 亲和
     - 节点名称、节点标签调度
     - dns策略
     - dns配置
     - 更新策略
     - 调度器

## 1.3.0

### Deployment

- 前端应用置于Kuboard展现层：Kuboard版本最好是 `v3.x`

- 主机别名：支持容器 `/etc/hosts` 添加映射

- 环境变量优化：

  1. 后端删除 `JAVA_HOME` 和 `LANG` 环境变量

     ```yaml
     - name: JAVA_HOME
       value: /usr/local/openjdk-8
     - name: LANG
       value: C.UTF-8
     ```

  2. 前端单独指定`LANG`环境变量

     ```yaml
     - name: LANG
       value: C.UTF-8
     ```

## 1.2.0

### Hpa

- hpa支持apiVersion版本：autoscaling/v2beta2，autoscaling/v2beta1，autoscaling/v2

  由Deployment版本限制，kubernetes版本需大于1.14-0

  支持以pod内存为指标进行自动扩缩容：服务平均内存大于80%(扩展指标70%+-10%死区)，扩容；最小副本数1，最大副本数5

### Deployment

- command优化：/bin/bash 替换 /bin/sh，解决容器内主进程 PID 不是 1 的问题
- 移除请求资源 requests 内存需求，满足hpa使用 `设置请求资源与hpa只能二选一`

### install.sh

- 添加快速部署应用脚本

## 1.1.0

### Deployment

- 优化Deployment命名空间配置：添加Release资源默认值，可不用在value.yaml中配置
- 添加部署后端command命令，自定义JAVA启动参数
- image字段：registry不写会使image字段前带`-`
- 优化java启动端口：使用容器端口作为`-Dserver.port`端口
- 添加资源限制：前端请求资源(30m/256Mi)，后端请求资源(30m/256Mi)和限制资源(1Gi)
- 添加port.name
- 添加容器端口默认值：未指定containerPort，前端默认：80，后端8080
- 添加后端探针：启动探针：给100秒启动；存活探针：1分钟4次,3次失败重启；就绪探针：1分钟4次，3次失败Service停止分发

### Service

- 优化前后端port：优化port逻辑，添加containerPort作为port值，并提供默认值前端80，后端8080
- targetPort：values.yaml设定为http，减少配置量

## 1.0.0

实现deployment、Service基本功能

------

# Deployment Chart使用介绍

## 快速入门

基于tgz包简单入门，还有很多方式可以部署应用

```bash
# 安装
$ helm install xxxname -n 命名空间 app1.4-1.4.0.tgz 
# 卸载
helm uninstall xxxname -n 命名空间
```

## 使用

### 导出配置

包里存在 `example.yaml` 文件，可复制一份出来使用，若为tgz包可使用如下命令导出

```bash
tar -zxOf app1.4-1.4.0.tgz app1.4/example.yaml > vbooster-gateway.yaml
```

`example.yaml` 是一份最简配置单，基本满足部署需要，若需要完整配置，可根据 `value.yaml` 进行修改，导出 `value.yaml` 命令

```bash
helm show values app1.4-1.4.0.tgz > vbooster-gateway.yaml
```

### 启动服务

```bash
helm install 服务名 app1.4-1.4.0.tgz -n 命名空间 -f vbooster-gateway.yaml
# or
helm install 服务名 app1.4-1.4.0.tgz -n 命名空间 -value vbooster-gateway.yaml
```

### 删除服务

```bash
helm uninstall -n 命名空间 服务名 
```

### 更新服务

```bash
helm upgrade -n 命名空间 服务名 app1.4-1.4.0.tgz -f vbooster-gateway.yaml
```

### 查看服务

```bash
helm list -n 命名空间
```

## 配置

| Key                                                          | 默认值                                                       | 描述                                             |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------ |
| isFrontend                                                   | false                                                        | nginx应用配置为true                              |
| name                                                         |                                                              | Deployment 和 Service 的名称                     |
| namespace                                                    |                                                              | 强制指定命名空间，可能造成资源和helm命名空间不同 |
| image.registry                                               |                                                              | 仓库名称                                         |
| image.repository                                             |                                                              | 镜像组                                           |
| image.tag                                                    | latest                                                       | 镜像标签                                         |
| image.pullPolicy                                             | Always                                                       | 镜像拉取策略                                     |
| image.PullSecret                                             |                                                              | 镜像拉取Secret                                   |
| containerPort                                                |                                                              | 容器声明端口                                     |
| extraContainerPort                                           |                                                              | 扩展容器端口                                     |
| createService                                                |                                                              | 创建Service                                      |
| replicaCount                                                 | 1                                                            | 副本数                                           |
| mount.volumeMounts                                           |                                                              | 容器内挂载地址                                   |
| mount.volumes                                                |                                                              | 卷                                               |
| env                                                          | \- name: TZ<br />  value: Asia/Shanghai                      | 环境变量                                         |
| JAVA_OPTS                                                    | -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Dfile.encoding=UTF-8 | jvm参数(只有后端可用)                            |
| podAnnotations                                               |                                                              | pod注解                                          |
| service.type                                                 | ClusterIP                                                    | Service类型                                      |
| service.ports.name                                           | http                                                         | Service端口名称                                  |
| service.ports.port                                           |                                                              | Service端口号                                    |
| service.ports.targetPort                                     | http                                                         | Service目标端口号                                |
| service.ports.nodePort                                       |                                                              | 节点暴露端口号                                   |
| service.extraPorts                                           |                                                              | 扩展其他端口                                     |
| service.sessionAffinity                                      |                                                              | 会话保持                                         |
| service.sessionAffinityConfig.\<br />clientIP.timeoutSeconds | 10800                                                        | 超时时间                                         |
| service.externalTrafficPolicy                                |                                                              | 外部流量策略                                     |
| service.loadBalancerSourceRanges                             |                                                              | 限制可以访问负载均衡器的源IP地址段               |
| service.loadBalancerIP                                       |                                                              | 负载均衡IP地址                                   |
| resources.requests                                           | cpu: 30m                                                     | 请求资源                                         |
| resources.limits                                             | memory: 1Gi                                                  | 限制资源(前端不生效)                             |
| hostAliases                                                  |                                                              | 主机别名                                         |
| probe.backend.enabled                                        | true                                                         | 后端探针总开关                                   |
| probe.backend.startupProbe.enabled                           | true                                                         | 后端启动探针开关                                 |
| probe.backend.startupProbe.内容                              | httpGet:<br />  path: /actuator/health<br />  port: http<br />failureThreshold: 30<br />periodSeconds: 4 | 后端启动探针内容                                 |
| probe.backend.livenessProbe.enabled                          | true                                                         | 后端存活探针开关                                 |
| probe.backend.livenessProbe.内容                             | tcpSocket:<br />  port: http<br />timeoutSeconds: 3<br />periodSeconds: 15 | 后端存活探针内容                                 |
| probe.backend.readinessProbe.enabled                         | true                                                         | 后端就绪探针开关                                 |
| probe.backend.readinessProbe.内容                            | httpGet:<br />  path: /actuator/health<br />  port: http<br />timeoutSeconds: 3<br />periodSeconds: 15 | 后端存活探针内容                                 |
| probe.frontend.enabled                                       | true                                                         | 前端探针总开关                                   |
| probe.frontend.startupProbe.enabled                          | true                                                         | 前端启动探针开关                                 |
| probe.frontend.startupProbe.内容                             | httpGet:<br />  path: /nginx_status<br />  port: http<br />failureThreshold: 5<br />periodSeconds: 2 | 前端启动探针内容                                 |
| probe.frontend.livenessProbe.enabled                         | true                                                         | 前端存活探针开关                                 |
| probe.frontend.livenessProbe.内容                            | tcpSocket:<br />  port: http<br />timeoutSeconds: 3<br />periodSeconds: 15<br /> | 前端存活探针内容                                 |
| probe.frontend.readinessProbe.enabled                        | true                                                         | 前端就绪探针开关                                 |
| probe.frontend.readinessProbe.内容                           | httpGet:<br />  path: /nginx_status<br />  port: http<br />timeoutSeconds: 3<br />periodSeconds: 15 | 前端存活探针内容                                 |
| probe.customStartupProbe                                     |                                                              | 自定义容器启动检查探针                           |
| probe.customLivenessProbe                                    |                                                              | 自定义容器存活检查探针                           |
| probe.customReadinessProbe                                   |                                                              | 自定义容器就绪检查探针                           |
| metrics.enabled                                              | true                                                         | 是否启用 Prometheus 监控指标                     |
| metrics.path                                                 | /actuator/prometheus                                         | 指标路径                                         |
| autoscaling.enabled                                          | false                                                        | hpa开关                                          |
| autoscaling.minReplicas                                      | 1                                                            | 最小副本集数                                     |
| autoscaling.maxReplicas                                      | 3                                                            | 最大副本集数                                     |
| autoscaling.targetMemory                                     | 75                                                           | 内存指标值                                       |
| skyWalking.enabled                                           | false                                                        | 链路追踪开关                                     |
| skyWalking.oapAdd                                            |                                                              | skyWalking-OAP地址                               |
| skyWalking.jarPath                                           | /skywalking/skywalking-agent/skywalking-agent.jar            | agent.jar地址                                    |
| tolerations                                                  |                                                              | 容忍                                             |
| affinity                                                     |                                                              | 亲和                                             |
| nodeSelector                                                 |                                                              | 节点标签选择部署节点                             |
| nodeName                                                     |                                                              | 节点名称选择部署节点                             |
| restartPolicy                                                | Always                                                       | 重启策略                                         |
| schedulerName                                                |                                                              | 调度器名称                                       |
| hostNetwork                                                  | false                                                        | 使用主机网络                                     |
| dnsPolicy                                                    | ClusterFirst                                                 | DNS策略                                          |
| dnsConfig                                                    |                                                              | dns配置                                          |
| revisionHistoryLimit                                         | 10                                                           | 历史版本数量                                     |
| strategy                                                     |                                                              | 更新策略                                         |

