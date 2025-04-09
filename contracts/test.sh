#!/bin/bash

# === test.sh ===
# USAGE: bash test.sh

set -euo pipefail

source deployment_variables.sh

# Ensure environment variables are available
if [[ -z "${FLASHLOANHANDLER:-}" || -z "${RPC1:-}" ]]; then
    echo "[!] FLASHLOANHANDLER or RPCs not set. Run deploy.sh first."
    exit 1
fi

HANDLER=$FLASHLOANHANDLER
RPC=$RPC1
CALLER_ADDRESS=$(cast wallet address --private-key "$PRIVATE_KEY")

echo "[+] Testing callFlashLoanHandler on handler $HANDLER"
echo "[+] Caller address: $CALLER_ADDRESS"
echo "[+] RPC: $RPC"

# Fetch initial balance
initial_balance=$(cast balance $CALLER_ADDRESS --rpc-url $RPC2 | grep -oE '^[0-9]+')
echo "Initial balance: $initial_balance wei"

# Call the flash loan handler
#cast send $HANDLER "callFlashLoanHandler(uint256 destinationChain)" 902 --rpc-url $RPC --private-key ""$PRIVATE_KEY"/"
cast send $FLASHLOANHANDLER "callFlashLoanHandler(uint256 destinationChain)" $CHAINID1 --rpc-url $RPC2 --private-key "$PRIVATE_KEY"

# Wait and retry loop
echo "[~] Waiting for up to 60 seconds for cross-chain message to complete..."

for i in {1..6}; do
    sleep 10
    final_balance=$(cast balance $CALLER_ADDRESS --rpc-url $RPC2 | grep -oE '^[0-9]+')
    echo "[~] Attempt $i: Current balance: $final_balance wei"

    if ((final_balance > initial_balance)); then
        echo "\n✅ Test PASSED: Balance increased"
        exit 0
    fi

done

echo "\n❌ Test FAILED: Balance did not increase after 60 seconds"
exit 1
