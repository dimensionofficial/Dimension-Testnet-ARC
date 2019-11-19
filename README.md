# 如何加入dimension测试网

出块节点服务器最低配置：2核8G内存，公网ip+3m以上带宽，300G以上SSD

测试网Chain ID：1c6ae7719a2a3b4ecb19584a30ff510ba1b6ded86e1fd8b8fc22f1179c622a32

## 一、获取代码

```sh
cd ~    # 退出当前目录，进入主目录
git clone https://github.com/dimensionofficial/dimension.git
cd dimension
git checkout v.maintest.1
git submodule update --init --recursive
sudo ./dimension_build.sh
sudo ./dimension_install.sh
```



## 二、获取BP账户

获取BP账户需先准备好相关信息（如服务器IP）并提交至[Github](https://github.com/dimensionofficial/dimension-testnet)上，然后联系测试网维护人员创建BP账户，具体步骤如下：

1、Fork本[repository](https://github.com/dimensionofficial/dimension-testnet)

2、Clone Fork的repository（不是本repo）到本地

```sh
git clone git@github.com:xxxxxxxx/dimension-testnet.git 
# xxxxxxxx替换为你自己的GitHub帐号
```

3、以[fudanlab.ini](https://github.com/dimensionofficial/dimension-testnet/blob/master/producer-info/fudanlab.ini)为例，新建bp-name.ini到producer-info文件夹中，bp-name为你的BP名称，ini文件中producer-name为链上bp账户名（12位字符，可选字符范围：1-5，a-z）

4、将BP名称和p2p-peer-address添加到config.ini文件末尾（以已有信息为例）

5、创建一个pull request将你的BP信息提交至[dimension-testnet](https://github.com/dimensionofficial/dimension-testnet)上

6、联系测试网维护人员创建BP账户以及转币



## 三、注册gnode及申请成为出块BP

**账户创建完成后**，首先将BP账户注册为gnode：

```shell
~/dimension/build/programs/keond/keond   # 启动钱包服务
cd ~/dimension/build/programs/cleon   # 打开另外一个终端，进入cleon目录
./cleon wallet create --to-console    # 默认创建名为default的钱包，记录显示的钱包密码
./cleon wallet import       # 导入BP账户。运行后会提示输入私钥，输入BP账户的私钥
./cleon wallet create_key    # 创建一对公私钥作为producer key
./cleon -u http://47.103.88.11:8001 system staketognode 'yourbpname' 'yourbpname' 'your_producer_pub_key' 
# yourbpname为你的BP账户名，your_producer_pub_key为上一条命令创建的公钥
```

然后发起提案申请成为出块节点：

```shell
./cleon -u http://47.103.88.11:8001 system newproposal 'yourbpname' 'yourbpname' 'block_height' 1 'consensus_type'
# yourbpname为你的BP账户名，'block_height' 'consensus_type' 任意uint数据，如0
```

发起提案成功后，联系微信(sdumaoziqi)对提案进行投票，票数达到一定后才可以执行提案。

注：若钱包15分钟未使用，会提示钱包被锁，需要用以下命令解锁钱包：
```shell
./cleon wallet unlock   # 根据提示输入钱包密码即可
```


## 四、准备配置文件

1、genesis.json

在~/dimension/build/programs/nodeon文件夹下创建 *genesis.json* 文件，填入以下内容：

```json
{
  "initial_timestamp": "2018-03-02T12:00:00.000",
  "initial_key": "EON8Znrtgwt8TfpmbVpTKvA2oB8Nqey625CLN8bCN3TEbgx86Dsvr",
  "initial_configuration": {
    "max_block_net_usage": 1048576,
    "target_block_net_usage_pct": 1000,
    "max_transaction_net_usage": 524288,
    "base_per_transaction_net_usage": 12,
    "net_usage_leeway": 500,
    "context_free_discount_net_usage_num": 20,
    "context_free_discount_net_usage_den": 100,
    "max_block_cpu_usage": 100000,
    "target_block_cpu_usage_pct": 500,
    "max_transaction_cpu_usage": 50000,
    "min_transaction_cpu_usage": 100,
    "max_transaction_lifetime": 3600,
    "deferred_trx_expiration_window": 600,
    "max_transaction_delay": 3888000,
    "max_inline_action_size": 4096,
    "max_inline_action_depth": 4,
    "max_authority_depth": 6
  },
  "initial_chain_id": "0000000000000000000000000000000000000000000000000000000000000000"
}
```

genesis.json文件定义了初始链状态，所有节点必须从相同的初始状态开始

2、config.ini

将[dimension-testnet](https://github.com/dimensionofficial/dimension-testnet)里的config.ini复制到~/dimension/build/programs/nodeon文件夹下，**注意要将自己的p2p-peer-address移除**



## 五、启动出块节点

准备好一切之后，便可启动出块节点，连接测试网：

```shell
cd ~/dimension/build/programs/nodeon

./nodeon --genesis-json ./genesis.json --config-dir ~/dimension/build/programs/nodeon --http-server-address 0.0.0.0:8888 --p2p-listen-endpoint 0.0.0.0:9876 --http-validate-host=false --producer-name 'yourbpname' --signature-provider='your_producer_pub_key'=KEY:'your_producer_private_key' --plugin eosio::http_plugin --plugin eosio::chain_api_plugin --plugin eosio::producer_plugin --plugin eosio::history_api_plugin
# yourbpname填入BP账户名; your_producer_pub_key、your_producer_private_key分别填入创建的producer key的公钥和私钥。
```

连接测试网，会先同步测试网中已生产的块，等待一段时间同步完成后，每0.5s会收到出块节点产出的块，终端显示如下示例信息：
```
2018-09-29T10:47:23.478 thread-0   producer_plugin.cpp:332       on_incoming_block    ] Received block 9838cc2c992c2725... #406196 @ 2018-09-29T10:47:23.500 signed by producer111h [trxs: 0, lib: 406028, conf: 0, latency: -21 ms]
2018-09-29T10:47:24.072 thread-0   producer_plugin.cpp:332       on_incoming_block    ] Received block 3624e2ab8697a1e1... #406197 @ 2018-09-29T10:47:24.000 signed by producer111i [trxs: 0, lib: 406040, conf: 120, latency: 72 ms]
```



## 六、执行提案

再打开另一个命令行终端窗口，输入以下命令：

```shell
cd ~/dimension/build/programs/cleon
./cleon get table eonio eonio proposals 
# 查看提案，获取第三步发起的提案id
./cleon system execproposal 'yourbpname' 'proposal_id'
# 执行提案，成为出块节点。其中yourbpname填入BP账户名，proposal_id为上一步获取的提案id

./cleon get schedule 
# 查看当前测试网出块节点
```
当nodeon同步到最新块，且BP账户出现在schedule中时，便可观察自己的节点是否正常出块





## 测试网维护人员联系方式

代码层次的技术问题请微信联系毛子旗：sdumaoziqi

节点连接测试网等其它问题请微信联系vc：Chen7ccc
