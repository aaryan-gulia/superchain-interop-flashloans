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
        uint256 amountIn;
        uint256 targetPrice;
        bool isActive;
        bool isExecuted;
    }

    mapping (uint256 => LimitOrder) public orders;
    uint256 public orderCount = 0;
    // TODO: Implement a dynamic array to store active orderIds to prevent iterating over all IDs EVER
    // https://ethereum.stackexchange.com/questions/1527/how-to-delete-an-element-at-a-certain-index-in-an-array

    event orderPlaced(uint256 orderId);
    event orderCancelled(uint256 orderId);
    event orderExecuted(uint256 orderId, uint256 executionPrice);

    address uniswapDummyContractAddress;
    UniswapDummyContract uniswapDummyContract;

    constructor(address _uniswapDummyContractAddress) {
        uniswapDummyContractAddress = _uniswapDummyContractAddress;
        uniswapDummyContract = UniswapDummyContract(payable(uniswapDummyContractAddress));
        token = uniswapDummyContract.getToken();
    }

    function placeLimitOrder(
        address tokenIn, 
        address tokenOut, 
        uint256 amountIn, 
        uint256 targetPrice
        ) external returns (uint256){
            orders[++orderCount] = LimitOrder({
                initiator: msg.sender,
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                amountIn: amountIn,
                targetPrice: targetPrice,
                isActive: true,
                isExecuted: false
            });

            emit orderPlaced(orderCount);
            return orderCount;
        }

    function cancelOrder(uint256 orderId) external {
        LimitOrder storage limitOrder = orders[orderId];
        require(limitOrder.isActive == true, "LimitOrder Does Not exist");
        require(limitOrder.initiator == msg.sender, "LimitOrder Was Not Does Not Belong To This Sender");
        require(limitOrder.isExecuted == false, "LimitOrder Has Been Executed");

        order.isActive == false;
        emit orderCancelled(orderId);
    }

    function cancelAllOrders() external{
        // TODO: Cancel all orders that belong to the msg.sender's address
    }

    function executeOrder() external {
        // TODO
    }

    function checkUpkeep() external view {
        // TODO
    }

    // TODO: Chainlink automation to ensure decentralised and trust-minimised execution

}
