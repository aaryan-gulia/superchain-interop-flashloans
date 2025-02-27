// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UniswapDummyContract, TestUSDToken} from "../src/UniswapDummyContract.sol";

contract UniswapDummyContractTest is Test{
    UniswapDummyContract public uniswapDummyContract;
    TestUSDToken public tusd;

    function setUp() public {
        tusd = new TestUSDToken();
        uniswapDummyContract = new UniswapDummyContract(tusd);

        // Fund contract with tokens
        tusd.mint(address(uniswapDummyContract), 100_000_000 ether);
        vm.deal(address(uniswapDummyContract), 100_000_000 ether);
    }


    function testEthTrading() public {
    address user = address(1234);
    vm.startPrank(user);
    vm.deal(user, 1000 ether);
    console.log("Test User ETH Balance Before:", user.balance);

    uniswapDummyContract.sellEth{value: 1 ether}();
    
    uint256 tusdBalance = tusd.balanceOf(user);
    require(tusdBalance > 0, "TUSD Balance is zero after selling ETH");

    tusd.approve(address(uniswapDummyContract), tusdBalance);
    uniswapDummyContract.buyEth(payable(user), tusdBalance);

    console.log("Test User ETH Balance After Buy:", user.balance);
    require(user.balance > 1000 ether, "ETH balance did not increase");
    vm.stopPrank();
}

}

