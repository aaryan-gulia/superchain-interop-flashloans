// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {TestUSDToken, UniswapDummyContract} from "./UniswapDummyContract.sol";

contract FlashLoanHandler {

    TestUSDToken public token;
    address uniswapDummyContractAddress;
    UniswapDummyContract uniswapDummyContract;

    constructor(address _uniswapDummyContractAddress) {
        uniswapDummyContractAddress = _uniswapDummyContractAddress;
        uniswapDummyContract = UniswapDummyContract(uniswapDummyContractAddress);
        token = uniswapDummyContract.getToken();
    }

    function executeArbitrage(uint256 ethAmount) private {
        require(ethAmount <= address(this).balance, "ETH Amount > Balance, Can't run arbitrage");
        uniswapDummyContract.sellEth{value: ethAmount}();
    
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "TOKEN Balance is zero after selling ETH");

        console.log("token balance: ", tokenBalance);
        token.approve(uniswapDummyContractAddress, tokenBalance);
        uniswapDummyContract.buyEth(payable(address(this)), tokenBalance);
    }

    function recieveEthForArbitrage() public payable {
        executeArbitrage(msg.value);
    }

    receive() external payable{}
}