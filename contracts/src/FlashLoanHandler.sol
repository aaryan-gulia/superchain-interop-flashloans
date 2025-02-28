// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {TestUSDToken, UniswapDummyContract} from "./UniswapDummyContract.sol";
import {ISuperchainWETH} from "@interop-lib/interfaces/ISuperchainWETH.sol";
import {IL2ToL2CrossDomainMessenger} from "@interop-lib/interfaces/IL2ToL2CrossDomainMessenger.sol";
import {CrossDomainMessageLib} from "@interop-lib/libraries/CrossDomainMessageLib.sol";

contract FlashLoanHandler {

    TestUSDToken public token;
    address uniswapDummyContractAddress;
    UniswapDummyContract uniswapDummyContract;

    address payable superchainWEthAddress = payable(0x4200000000000000000000000000000000000024);
    ISuperchainWETH superchainWEth = ISuperchainWETH(superchainWEthAddress);
    IL2ToL2CrossDomainMessenger public constant messenger =
        IL2ToL2CrossDomainMessenger(0x4200000000000000000000000000000000000023);

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

    function recieveEthForArbitrageSourceChain(uint256 destinationChain) public payable {
        bytes32 sendEthMsgHash = superchainWEth.sendETH{value: msg.value}(address(this), destinationChain);

        messenger.sendMessage(
            destinationChain,
            address(this),
            abi.encodeWithSelector(
                this.recieveEthForArbitrageDestinationChain.selector,
                sendEthMsgHash,
                uint256(block.chainid),
                msg.sender
                )
        );
    }

    function recieveEthForArbitrageDestinationChain(bytes32 sendEthMsgHash, uint256 sourceChain, address caller) external {
        CrossDomainMessageLib.requireCrossDomainCallback();
        CrossDomainMessageLib.requireMessageSuccess(sendEthMsgHash);

        executeArbitrage(address(this).balance);

        bytes32 sendEthMsgHashBack = superchainWEth.sendETH{value: address(this).balance}(address(this), sourceChain);
        
        messenger.sendMessage(
            sourceChain,
            address(this),
            abi.encodeWithSelector(
                this.recieveEthOnSourceChainFromDestinationChain.selector,
                sendEthMsgHashBack,
                caller
                )
            );
    }

    function recieveEthOnSourceChainFromDestinationChain(bytes32 sendEthMsgHash, address caller) external{
        CrossDomainMessageLib.requireCrossDomainCallback();
        CrossDomainMessageLib.requireMessageSuccess(sendEthMsgHash);

        payable(caller).call{value: address(this).balance}("");
    }

    receive() external payable{}
}