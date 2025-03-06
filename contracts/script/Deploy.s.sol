// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {ICreateX} from "createx/ICreateX.sol";

import {DeployUtils} from "../libraries/DeployUtils.sol";
import {TestUSDToken, UniswapDummyContract} from "../src/UniswapDummyContract.sol";
import {FlashBorrower} from "../src/FlashBorrower.sol";
import {FlashLoanHandler} from "../src/FlashLoanHandler.sol";
import {FlashLoanVault} from "../src/FlashLoanVault.sol";

contract Deploy is Script {
    /// @notice Array of RPC URLs to deploy to, deploy to supersim 901 and 902 by default.
    string[] private rpcUrls = ["http://localhost:9545", "http://localhost:9546"];
    //string[] private rpcUrls = ["https://interop-alpha-0.optimism.io/", "https://interop-alpha-1.optimism.io/"];

    /// @notice Modifier that wraps a function in broadcasting.
    modifier broadcast() {
        vm.startBroadcast(msg.sender);
        _;
        vm.stopBroadcast();
    }

    function run() public {
        for (uint256 i = 0; i < rpcUrls.length; i++) {
            string memory rpcUrl = rpcUrls[i];

            console.log("Deploying to RPC: ", rpcUrl);
            vm.createSelectFork(rpcUrl);
            address testUSDTokenAddress = deployTestUSDToken();
            address uniswapDummyContractAddress = deployUniswapDummyContract(testUSDTokenAddress);
            address flashBorrowerAddress = deployFlashBorrower(uniswapDummyContractAddress);
            address flashLoanVaultAddress = deployFlashLoanVault();
            address flashLoanHandlerAddress = deployFlashLoanHandler(flashBorrowerAddress, flashLoanVaultAddress);
        }
    }

    function deployFlashLoanVault() public payable broadcast returns (address addr_){
        bytes memory initCode = abi.encodePacked(type(FlashLoanVault).creationCode);
        addr_ = DeployUtils.deployContract("FlashLoanVault", _implSalt(), initCode);
    }

    function deployTestUSDToken() public broadcast returns (address addr_){
        bytes memory initCode = abi.encodePacked(type(TestUSDToken).creationCode);
        addr_ = DeployUtils.deployContract("TestUSDToken", _implSalt(), initCode);
    }

    function deployUniswapDummyContract(address testUSDTokenAddress) public payable broadcast returns (address addr_){
        bytes memory initCode = abi.encodePacked(type(UniswapDummyContract).creationCode, abi.encode(testUSDTokenAddress));
        addr_ = DeployUtils.deployContract("UniswapDummyContract", _implSalt(), initCode);
    }

    function deployFlashBorrower(address uniswapDummyContractAddress) public payable broadcast returns (address addr_){
        bytes memory initCode = abi.encodePacked(
            type(FlashBorrower).creationCode,
            abi.encode(uniswapDummyContractAddress)
        );
        addr_ = DeployUtils.deployContract("FlashBorrower", _implSalt(), initCode);
    }

    function deployFlashLoanHandler(address flashBorrowerAddress, address flashLoanVaultAddress) 
    public broadcast returns (address addr_){
        bytes memory initCode = abi.encodePacked(
            type(FlashLoanHandler).creationCode, 
            abi.encode(flashBorrowerAddress, flashLoanVaultAddress)
            );
        addr_ = DeployUtils.deployContract("FlashLoanHandler", _implSalt(), initCode);
    }

    /// @notice The CREATE2 salt to be used when deploying a contract.
    function _implSalt() internal view returns (bytes32) {
        return keccak256(abi.encodePacked(vm.envOr("DEPLOY_SALT", string("ethers phoenix"))));
    }
}