#!/bin/bash

# === deploy.sh ===
# USAGE: bash deploy.sh

set -e

WALLET_ADDRESS=$(cast wallet address --private-key "$PRIVATE_KEY")
DEPLOY_SCRIPT="./script/Deploy.s.sol"
DEPLOY_LOG="deploy_log.txt"

# Step 1: Deploy contracts on Supersim chains (local forks)
echo "\n[+] Deploying contracts to Supersim chains..."
forge script "$DEPLOY_SCRIPT" --slow --multi --broadcast --private-key "$PRIVATE_KEY" -vvv >"$DEPLOY_LOG"

# Step 2: Parse contract addresses (same across both chains)
LOGS=$(cat "$DEPLOY_LOG")

extract_address() {
    local contract="$1"
    echo "$LOGS" | grep -Ei "$contract (already )?deployed at|Deployed $contract at address" | head -n 1 | sed -E 's/.*at (address: )?([^ ]+) on.*/\2/'
}

UNISWAPCONTRACT=$(extract_address "UniswapDummyContract")
VAULTCONTRACT=$(extract_address "FlashLoanVault")
FLASHLOANHANDLER=$(extract_address "FlashLoanHandler")

export UNISWAPCONTRACT
export VAULTCONTRACT

echo "\n[+] Parsed contract addresses:"
echo "UNISWAPCONTRACT=$UNISWAPCONTRACT"
echo "VAULTCONTRACT=$VAULTCONTRACT"
echo "FLASHLOANHANDLER=$FLASHLOANHANDLER"

# Step 3: Parse RPC URLs and chain IDs
RPC1=$(echo "$LOGS" | grep "Deploying to RPC" | head -n 1 | sed -E 's/.*RPC: *([^ ]+).*/\1/')
RPC2=$(echo "$LOGS" | grep "Deploying to RPC" | tail -n 1 | sed -E 's/.*RPC: *([^ ]+).*/\1/')

CHAINID1=$(echo "$LOGS" | grep "chain id:" | head -n 1 | sed -E 's/.*chain id: *([0-9]+).*/\1/')
CHAINID2=$(echo "$LOGS" | grep "chain id:" | tail -n 1 | sed -E 's/.*chain id: *([0-9]+).*/\1/')

export RPC1
export RPC2
export CHAINID1
export CHAINID2

# Step 4: Fund Uniswap and Vault contract with ETH on both Supersim chains

echo "\n[+] Funding contracts on both chains..."

get_tenth_balance() {
    local rpc="$1"
    local balance=$(cast balance $WALLET_ADDRESS --rpc-url $rpc | grep -oE '^[0-9]+')
    echo $((balance / 100))
}

AMOUNT1=$(get_tenth_balance $RPC1)
AMOUNT2=$(get_tenth_balance $RPC2)

echo "\n[+] Transferring $AMOUNT1 wei from Chain 1"
echo "[+] Transferring $AMOUNT2 wei from Chain 2"

# Chain 1 → Chain 2
cast send 0x4200000000000000000000000000000000000024 "sendETH(address _to, uint256 _chainId)" \
    $UNISWAPCONTRACT $CHAINID2 --value $AMOUNT1 \
    --rpc-url $RPC1 \
    --private-key "$PRIVATE_KEY"

cast send 0x4200000000000000000000000000000000000024 "sendETH(address _to, uint256 _chainId)" \
    $VAULTCONTRACT $CHAINID1 --value $AMOUNT1 \
    --rpc-url $RPC2 \
    --private-key "$PRIVATE_KEY"

# Chain 2 → Chain 1
cast send 0x4200000000000000000000000000000000000024 "sendETH(address _to, uint256 _chainId)" \
    $UNISWAPCONTRACT $CHAINID1 --value $AMOUNT2 \
    --rpc-url $RPC2 \
    --private-key "$PRIVATE_KEY"

cast send 0x4200000000000000000000000000000000000024 "sendETH(address _to, uint256 _chainId)" \
    $VAULTCONTRACT $CHAINID2 --value $AMOUNT2 \
    --rpc-url $RPC1 \
    --private-key "$PRIVATE_KEY"

echo "\n[+] Deployment and funding complete."

cat <<EOF >deployment_variables.sh
export FLASHLOANHANDLER=$FLASHLOANHANDLER
export RPC1=$RPC1
export CHAINID1=$CHAINID1
export RPC2=$RPC2
export CHAINID2=$CHAINID2
# Add other vars as needed
EOF

echo "Variables saved to deployment_variables.sh file"
