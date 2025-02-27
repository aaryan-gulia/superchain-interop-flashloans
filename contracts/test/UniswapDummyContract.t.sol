// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {UniswapDummyContract, TestUSDToken} from "../src/UniswapDummyContract.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}

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
    vm.deal(user, 1000 ether); // Fund test contract with ETH
    console.log("Test Contract ETH Balance Before:", user.balance);

    // Sell 1 ETH to get TUSD
    uniswapDummyContract.sellEth{value: 1 ether}();
    
    uint256 tusdBalance = tusd.balanceOf(user);
    console.log("TUSD received after selling 1 ETH:", tusdBalance);

    // Ensure contract actually received TUSD
    require(tusdBalance > 0, "TUSD Balance is zero after selling ETH");

    // Approve contract to spend TUSD
    tusd.approve(address(uniswapDummyContract), tusdBalance);

    // Check UniswapDummyContract ETH Balance
    console.log("UniswapDummyContract ETH Balance Before Buy:", address(uniswapDummyContract).balance);

    // Buy ETH using TUSD
    uniswapDummyContract.buyEth(payable(user), tusdBalance);

    console.log("Test Contract ETH Balance After Buy:", address(this).balance);

    // Ensure ETH balance increased
    require(address(this).balance > 1000 ether, "ETH balance did not increase");
    vm.stopPrank();
}

}

