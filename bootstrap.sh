#!/bin/bash

# Ensure that needed env vars are set and have valid contents
if [ -z "$RPC_USER" ]; then
    echo "The RPC_USER environment variable is empty or unset."
    exit 1
fi

if [ -z "$RPC_PASSWORD" ]; then
    echo "The RPC_PASSWORD environment variable is empty or unset."
    exit 1
fi

if [ -z "$ENABLE_TESTNET" ]; then
    echo "The ENABLE_TESTNET environment variable is empty or unset."
    exit 1
else
    if [ "$ENABLE_TESTNET" != "0" ] && [ "$ENABLE_TESTNET" != "1" ]; then
        echo "The ENABLE_TESTNET environment variable is set to a value that is neither 0 nor 1."
        exit 1
    elif [ "$ENABLE_TESTNET" == "1" ]; then
        echo "*** Node running on TESTNET blockchain!" 1>&2
    fi
fi

if [ -z "$DEBUG" ]; then
    echo "The DEBUG environment variable is empty or unset."
    exit 1
else
    if [ "$DEBUG" != "0" ] && [ "$DEBUG" != "1" ]; then
        echo "The DEBUG environment variable is set to a value that is neither 0 nor 1."
        exit 1
    elif [ "$ENABLE_TESTNET" == "1" ]; then
        echo "*** Node running with DEBUG enabled!" 1>&2
    fi
fi

# Update configuration
sed -i "s/rpcuser=\S+/rpcuser=${RPC_USER}/" /home/btcd/.bitcoin/bitcoin.conf
sed -i "s/rpcpassword=\S+/rpcpassword=${RPC_PASSWORD}/" /home/btcd/.bitcoin/bitcoin.conf
sed -i "s/testnet=[01]/testnet=${ENABLE_TESTNET}/" /home/btcd/.bitcoin/bitcoin.conf
sed -i "s/debug=[01]/debug=${DEBUG}/" /home/btcd/.bitcoin/bitcoin.conf

# Launch Bitcoin daemon
echo "*** Now running 'bitcoind'..."
exec bitcoind