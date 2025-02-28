// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
// import {FlashLoanVault} from "../src/UniswapDummyContract.sol";

// contract FlashLoanVault is Test{
//     FlashLoanVault public FlashLoanVaultContract;

//     function setUp() public {
//         FlashLoanVaultContract = new FlashLoanVault();

//         // Fund contract with tokens
//         vm.deal(address(FlashLoanVaultContract), 100_000_000 ether);
//     }


//     function testEthTrading() public {
//         address user = address(1234);
//         vm.startPrank(user);
//         vm.deal(user, 1000 ether);
//         console.log("Test User ETH Balance Before:", user.balance);


//         vm.stopPrank();
//     }

// }

