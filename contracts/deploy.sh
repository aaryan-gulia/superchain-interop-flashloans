#!/bin/bash

# === deploy_and_fund.sh ===
# USAGE: bash deploy_and_fund.sh

set -e

PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
DEPLOY_SCRIPT="./script/Deploy.s.sol"
DEPLOY_LOG="deploy_log.txt"

# Step 1: Deploy contracts on Supersim chains (local forks)
echo "\n[+] Deploying contracts to Supersim chains..."
forge script "$DEPLOY_SCRIPT" --slow --multi --broadcast --private-key "$PRIVATE_KEY" -vvv > "$DEPLOY_LOG"

# Step 2: Parse contract addresses (same across both chains)
LOGS=$(cat "$DEPLOY_LOG")

extract_address() {
  local contract="$1"
  echo "$LOGS" | grep "Deployed $contract at address:" | head -n 1 | sed -E 's/.*address: ([^ ]+).*/\1/'
}

UNISWAPCONTRACT=$(extract_address "UniswapDummyContract")
VAULTCONTRACT=$(extract_address "FlashLoanVault")

export UNISWAPCONTRACT
export VAULTCONTRACT

echo "\n[+] Parsed contract addresses:"
echo "UNISWAPCONTRACT=$UNISWAPCONTRACT"
echo "VAULTCONTRACT=$VAULTCONTRACT"

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

# Chain 1 → Chain 2
cast send 0x4200000000000000000000000000000000000024 "sendETH(address _to, uint256 _chainId)" \
  $UNISWAPCONTRACT $CHAINID2 --value 0.01ether \
  --rpc-url $RPC1 \
  --private-key "$PRIVATE_KEY"

cast send 0x4200000000000000000000000000000000000024 "sendETH(address _to, uint256 _chainId)" \
  $VAULTCONTRACT $CHAINID1 --value 0.01ether \
  --rpc-url $RPC2 \
  --private-key "$PRIVATE_KEY"

# Chain 2 → Chain 1
cast send 0x4200000000000000000000000000000000000024 "sendETH(address _to, uint256 _chainId)" \
  $UNISWAPCONTRACT $CHAINID1 --value 0.01ether \
  --rpc-url $RPC2 \
  --private-key "$PRIVATE_KEY"

cast send 0x4200000000000000000000000000000000000024 "sendETH(address _to, uint256 _chainId)" \
  $VAULTCONTRACT $CHAINID2 --value 0.01ether \
  --rpc-url $RPC1 \
  --private-key "$PRIVATE_KEY"

echo "\n[+] Deployment and funding complete."

