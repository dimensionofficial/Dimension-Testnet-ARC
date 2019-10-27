# 动态节点逻辑测试脚本说明

## 环境准备

- 本地nodeos已启动且连接到测试网

## 运行说明

```shell
git clone https://github.com/dimensionofficial/dimension-testnet.git
cd dimension-testnet/test
./logic.sh
```

运行后会提示输入本地programs路径以及本地已连接测试网的nodeos的http-server-address端口，例如可分别输入

```shell
../../dimension/build/programs
8888
```

正确输入即可运行逻辑测试脚本，出现下图即为验证通过

![pass.png](https://github.com/dimensionofficial/dimension-testnet/blob/master/test/pass.png)

## 测试内容

脚本主要测试以下逻辑：

- 非治理节点是否能发起提案
- 非治理节点是否能更新治理节点信息
- 非治理节点是否能执行已完成提案
- 治理节点是否能执行未完成提案
