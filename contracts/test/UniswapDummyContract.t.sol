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
    }


    function testEthSelling() public {
        vm.deal(address(this), 1000 ether); // Give test contract ETH
        uniswapDummyContract.sellEth{value: 1 ether}();  
    }
}

