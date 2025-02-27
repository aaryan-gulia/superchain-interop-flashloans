// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {TestUSDToken, UniswapDummyContract} from "./UniswapDummyContract.sol";

contract FlashLoanHandler {

    TestUSDToken public token;
    address uniswapDummyContractAddress;
    UniswapDummyContract uniswapDummyContract;

    constructor(address _uniswapDummyContractAddress) {
        uniswapDummyContractAddress = _uniswapDummyContractAddress;
        uniswapDummyContract = UniswapDummyContract(uniswapDummyContractAddress);
        token = uniswapDummyContract.token;
    }

    function executeArbitrage() {
        uint256 ethAmount = address(this).balance;
        require(ethAmount > 0);
        uniswapDummyContract.sellEth{value: ethAmount}();
    
        uint256 tusdBalance = token.balanceOf(address(this));
        require(tusdBalance > 0, "TUSD Balance is zero after selling ETH");

        tusd.approve(address(uniswapDummyContract), tusdBalance);
        uniswapDummyContract.buyEth(payable(user), tusdBalance);
    }

    function recieveEth() public {
        if(uniswapDummyContract.premium_percent > 0) {
            executeArbitrage();
        }
    }
}