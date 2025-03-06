// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {UniswapDummyContract, TestUSDToken} from "./UniswapDummyContract.sol";
import {IFlashBorrower} from "./InterfaceFlashBorrower.sol";

contract FlashBorrower is IFlashBorrower{

    TestUSDToken public token;
    address uniswapDummyContractAddress;
    UniswapDummyContract uniswapDummyContract;

    constructor(address _uniswapDummyContractAddress) {
        uniswapDummyContractAddress = _uniswapDummyContractAddress;
        uniswapDummyContract = UniswapDummyContract(payable(uniswapDummyContractAddress));
        token = uniswapDummyContract.getToken();
    }


    function onFlashLoan(uint256 amount, address flashLoanHandlerAddress) external payable override{
        executeArbitrage(amount);
        payable(flashLoanHandlerAddress).call{value:address(this).balance}("");
    }

    function executeArbitrage(uint256 ethAmount) private {
        require(ethAmount <= address(this).balance, "ETH Amount > Balance, Can't run arbitrage");
        uniswapDummyContract.sellEth{value: ethAmount}();
    
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "TOKEN Balance is zero after selling ETH");

        token.approve(uniswapDummyContractAddress, tokenBalance);
        uniswapDummyContract.buyEth(payable(address(this)), tokenBalance);
    }

    receive() external payable{}
}


