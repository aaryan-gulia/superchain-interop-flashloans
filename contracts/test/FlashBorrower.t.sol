// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {FlashBorrower} from "../src/FlashBorrower.sol";
import {UniswapDummyContract, TestUSDToken} from "../src/UniswapDummyContract.sol";

contract UniswapDummyContractTest is Test{
    UniswapDummyContract public uniswapDummyContract;
    TestUSDToken public tusd;
    FlashBorrower public flashBorrower;

    function setUp() public {
        tusd = new TestUSDToken();
        uniswapDummyContract = new UniswapDummyContract(tusd);

        flashBorrower = new FlashBorrower(address(uniswapDummyContract));

        // Fund contract with tokens
        tusd.mint(address(uniswapDummyContract), 100_000_000 ether);
        vm.deal(address(uniswapDummyContract), 100_000_000 ether);
    }

    function testEthTrading() public {
        address user = address(1234);
        vm.startPrank(user);
        vm.deal(user, 1000 ether);
    
        uint256 ethAmount = user.balance;
        flashBorrower.onFlashLoan{value : ethAmount}(ethAmount, user);

        require(user.balance > 1000 ether, "ETH balance did not increase");
        vm.stopPrank();
    }

}