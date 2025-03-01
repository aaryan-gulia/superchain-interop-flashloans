// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
// import {FlashLoanHandler, UniswapDummyContract, TestUSDToken} from "../src/FlashLoanHandler.sol";

// contract FlashLoanHandlerTest is Test{
//     FlashLoanHandler public flashLoanHandler;
//     UniswapDummyContract public uniswapDummyContract;
//     TestUSDToken public tusd;

//     function setUp() public {
//         tusd = new TestUSDToken();
//         uniswapDummyContract = new UniswapDummyContract(tusd);
//         flashLoanHandler = new FlashLoanHandler(address(uniswapDummyContract));

//         tusd.mint(address(uniswapDummyContract), 100_000_000 ether);
//         vm.deal(address(uniswapDummyContract), 100_000_000 ether);
//     }

//     function testFlashLoanHandlerOnDestinationChain() public {
//         address user = address(1234);
//         vm.startPrank(user);
//         vm.deal(user, 1000 ether);
//         flashLoanHandler.recieveEthForArbitrage{value: 1 ether}();
//         console.log("Final Contract Balance", address(flashLoanHandler).balance);
//         vm.stopPrank();
//     }
// }