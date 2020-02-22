#!/bin/bash
function clean(){
    pid=$(cat $WALLETDIR/keosd.pid)
    echo "kill keosd pid : $pid "
    kill $pid
    rm $WALLETDIR/keosd.pid
    rm $WALLETDIR/$WALLETNAME.wallet
    history -c
    history -w
}

function test(){
    if [ $1 -eq 0 ];then
        echo "test failed, please check"
        clean
        exit 2
    fi
}

function random()
{
    string="abcdefghijklmnopqrstuvwxyz12345"
    str_length=${#string}
    num=$(date +%s%N)
    ((retnum=num%str_length))
    gnodename=$gnodename${string:$retnum:1}
}

cd `pwd`
# step 1 : find the unused port and get the cleos
WALLETPORT=("8900" "9900" "8901" "8902" "9903" "8904" "8905" "9906")
for p in ${WALLETPORT[*]}
    do
        r=`netstat -ano | grep $p | wc -l`
        if [ $r -eq 0 ];then
            WALLETURL="127.0.0.1:$p"
            break
        fi
    done

cleos version client > /dev/null
if [ $? -eq 0 ]
    then
        cleos="cleos -u http://$APIURL --wallet-url http://$WALLETURL " "$@"
    else
        cleos="$PDIR/cleos/cleos -u http://$APIURL --wallet-url http://$WALLETURL " "$@"
fi

# step 2 : start keosd wallet, create new wallet and import testaccount1 account
WALLETDIR="./test-wallet"
WALLETNAME="test"
PRIVATE_KEY="5J87xzDDoJes9uzLE7ZNi71cjhnpRRha7ZeKMtxjpmfveZkKGTE"
mkdir -p $WALLETDIR
if [ -e $WALLETDIR/$WALLETNAME.wallet ]
    then
        rm -r $WALLETDIR/$WALLETNAME.wallet
fi
keosd --http-server-address $WALLETURL -d $WALLETDIR & echo $! > $WALLETDIR/keosd.pid
pid=$(cat $WALLETDIR/keosd.pid)
p=`ps -ef | grep $pid | wc -l`
if [ $p -eq 1 ];then
    $PDIR/keosd/keosd --http-server-address $WALLETURL -d $WALLETDIR & echo $! > $WALLETDIR/keosd.pid        
fi
sleep 0.5
$cleos wallet create -n $WALLETNAME --to-console
$cleos wallet import -n $WALLETNAME --private-key $PRIVATE_KEY
