// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {UniswapDummyContract, TestUSDToken} from "./UniswapDummyContract.sol";
import {ISuperchainWETH} from "@interop-lib/interfaces/ISuperchainWETH.sol";
import {IL2ToL2CrossDomainMessenger} from "@interop-lib/interfaces/IL2ToL2CrossDomainMessenger.sol";
import {CrossDomainMessageLib} from "@interop-lib/libraries/CrossDomainMessageLib.sol";
import {PredeployAddresses} from "@interop-lib/libraries/PredeployAddresses.sol";

contract LimitOrderHandler{
    struct LimitOrder {
        address initiator;
        address tokenIn;
        address tokenOut;
        address amountIn;
        address exchangeRate;
        address initTimeStamp;
        bool isActive;
        bool isExecuted;
    }

    mapping (uint256 => LimitOrder) public orders;

    address uniswapDummyContractAddress;
    UniswapDummyContract uniswapDummyContract;

    constructor(address _uniswapDummyContractAddress) {
        uniswapDummyContractAddress = _uniswapDummyContractAddress;
        uniswapDummyContract = UniswapDummyContract(payable(uniswapDummyContractAddress));
        token = uniswapDummyContract.getToken();
    }

    function placeLimitOrder() external {
        // TODO
    }

    function cancelOrder() external {
        // TODO
    }

    function executeOrder() external {
        // TODO
    }

    function checkUpkeep() external view {
        // TODO
    }

    // TODO: Chainlink automation to ensure decentralised and trust-minimised execution

}
