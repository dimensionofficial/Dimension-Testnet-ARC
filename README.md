# How to join the dimension testnet

Minimum node server configuration: 2 core 8G memory, public network ip + 3m bandwidth, SSD over 300G

Testnet Chain ID：1c6ae7719a2a3b4ecb19584a30ff510ba1b6ded86e1fd8b8fc22f1179c622a32

## Get the code

```sh
cd ~    # Exit the current directory and enter the home directory
git clone https://github.com/dimensionofficial/dimension.git
cd dimension
git checkout v.maintest.1
git submodule update --init --recursive
sudo ./dimension_build.sh
sudo ./dimension_install.sh
```



## Get a BP account

To obtain a BP account, you must first prepare relevant information (such as the server IP) and submit it to [Github](https://github.com/dimensionofficial/dimension-testnet), and then contact the testnet maintainer to create a BP account:

1. Fork this [repository](https://github.com/dimensionofficial/dimension-testnet)

2. Clone Fork's repository (not this repo) to local

```sh
git clone git@github.com:xxxxxxxx/dimension-testnet.git 
# Replace xxxxxxxx with your own GitHub account
```

3. Take [fudanlab.ini](https://github.com/dimensionofficial/dimension-testnet/blob/master/producer-info/fudanlab.ini) as an example, create a new bp-name.ini into the producer-info folder, bp-name is your BP name, and producer-name in the ini file is the bp account name on the chain (12 characters, optional character range: 1-5, a-z)

4. Add the BP name and p2p-peer-address to the end of the config.ini file (take the existing information as an example)

5. Create a pull request to submit your BP information to [dimension-testnet](https://github.com/dimensionofficial/dimension-testnet)

6. Contact the testnet maintenance staff to create a BP account and transfer coins



## Register gnode and apply to become a block BP

**After the account creation completed**, register the BP account as a gnode firstly：

```shell
~/dimension/build/programs/keond/keond   # Start wallet service
cd ~/dimension/build/programs/cleon   # Open another terminal and go to the cleon directory
./cleon wallet create --to-console    # Create a wallet named default by default, record the wallet password displayed
./cleon wallet import       # After running, you will be prompted to enter the private key. Enter the private key of the BP account.
./cleon wallet create_key    # Create a pair of public and private keys as producer keys
./cleon -u http://47.103.88.11:8001 system staketognode 'yourbpname' 'yourbpname' 'your_producer_pub_key' 
# yourbpname is your BP account name, your_producer_pub_key is the public key created by the previous command
```

Then initiate a proposal application to become a block node:

```shell
./cleon -u http://47.103.88.11:8001 system newproposal 'yourbpname' 'yourbpname' 'block_height' 1 'consensus_type'
# yourbpname is your BP account name, 'block_height' 'consensus_type' is arbitrary uint data, such as 0
```

After successfully launching the proposal, contact the WeChat user (sdumaoziqi) to vote on the proposal, and the proposal can be executed after the number of votes reaches a certain number.

Note: If the wallet is not used for 15 minutes, it will prompt the wallet to be locked. You need to unlock the wallet with the following command:
```shell
./cleon wallet unlock   # Enter the wallet password as prompted
```


## Prepare the configuration file

1. genesis.json


Create a *genesis.json* file in the ~/dimension/build/programs/nodeon folder and fill in the following: 

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

The genesis.json file defines the initial chain state. All nodes must start from the same initial state.

2. config.ini

Copy the config.ini in [dimension-testnet](https://github.com/dimensionofficial/dimension-testnet) to the ~/dimension/build/programs/nodeon folder, **Note that you must remove your p2p-peer-address**



## Start block node

After everything is ready, you can start the block node and connect to the testnet:

```shell
cd ~/dimension/build/programs/nodeon

./nodeon --genesis-json ./genesis.json --config-dir ~/dimension/build/programs/nodeon --http-server-address 0.0.0.0:8888 --p2p-listen-endpoint 0.0.0.0:9876 --http-validate-host=false --producer-name 'yourbpname' --signature-provider='your_producer_pub_key'=KEY:'your_producer_private_key' --plugin eosio::http_plugin --plugin eosio::chain_api_plugin --plugin eosio::producer_plugin --plugin eosio::history_api_plugin
# Fill yourbpname into the BP account name; fill your_producer_pub_key and your_producer_private_key into the public key and private key of the producer key you created respectively.
```

After connecting to the testnet, the blocks produced in the testnet will be synchronized first. After waiting for a period of time to complete the synchronization, the blocks produced by the block node will be received every 0.5s. The following example information will be displayed in the terminal:
```
2018-09-29T10:47:23.478 thread-0   producer_plugin.cpp:332       on_incoming_block    ] Received block 9838cc2c992c2725... #406196 @ 2018-09-29T10:47:23.500 signed by producer111h [trxs: 0, lib: 406028, conf: 0, latency: -21 ms]
2018-09-29T10:47:24.072 thread-0   producer_plugin.cpp:332       on_incoming_block    ] Received block 3624e2ab8697a1e1... #406197 @ 2018-09-29T10:47:24.000 signed by producer111i [trxs: 0, lib: 406040, conf: 120, latency: 72 ms]
```



## Implementation proposal

Open another command-line terminal and enter the following command:

```shell
cd ~/dimension/build/programs/cleon
./cleon get table eonio eonio proposals 
# View the proposal and get the proposal id initiated in the third step
./cleon system execproposal 'yourbpname' 'proposal_id'
# Where yourbpname is filled in the BP account name, proposal_id is the proposal id obtained in the previous step

./cleon get schedule 
# View the current testnet block node
```
When nodeon is synchronized to the latest block, and the BP account appears in the schedule, you can observe whether your node is producing blocks






