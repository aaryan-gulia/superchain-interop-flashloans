// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {TestUSDToken, UniswapDummyContract} from "./UniswapDummyContract.sol";
import {FlashLoanVault} from "./FlashLoanVault.sol";
import {ISuperchainWETH} from "@interop-lib/interfaces/ISuperchainWETH.sol";
import {IL2ToL2CrossDomainMessenger} from "@interop-lib/interfaces/IL2ToL2CrossDomainMessenger.sol";
import {CrossDomainMessageLib} from "@interop-lib/libraries/CrossDomainMessageLib.sol";

contract FlashLoanHandler {

    event flashLoanRecieved(bytes32 indexed flashLoanId, uint256 ethAmount, uint256 chainid, address indexed user);
    event flashLoanRepayed(bytes32 indexed flashLoanId, uint256 ethAmount, uint256 chainid, address indexed user);
    event soldEth(bytes32 indexed flashLoanId, uint256 ethAmount, uint256 chainid, address indexed user);
    event boughtEth(bytes32 indexed flashLoanId, uint256 ethAmount, uint256 chainid, address indexed user);
    event sentProfit(bytes32 indexed flashLoanId, uint256 ethAmount, uint256 chainid, address indexed user);
    event noProfit();

    TestUSDToken public token;
    address uniswapDummyContractAddress;
    UniswapDummyContract uniswapDummyContract;

    address payable superchainWEthAddress = payable(0x4200000000000000000000000000000000000024);
    ISuperchainWETH superchainWEth = ISuperchainWETH(superchainWEthAddress);
    IL2ToL2CrossDomainMessenger public constant messenger =
        IL2ToL2CrossDomainMessenger(0x4200000000000000000000000000000000000023);

    address payable flashLoanVaultAddress;
    FlashLoanVault flashLoanVault;

    constructor(address _uniswapDummyContractAddress, address _flashLoanVaultAddress) {
        uniswapDummyContractAddress = _uniswapDummyContractAddress;
        uniswapDummyContract = UniswapDummyContract(payable(uniswapDummyContractAddress));
        token = uniswapDummyContract.getToken();

        flashLoanVaultAddress = payable(_flashLoanVaultAddress);
        flashLoanVault = FlashLoanVault(flashLoanVaultAddress);

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

    function recieveEthForArbitrageSourceChain(uint256 destinationChain, address caller, uint256 laonAmount, bytes32 flashLoanId) 
    public payable {
        bytes32 sendEthMsgHash = superchainWEth.sendETH{value: address(this).balance}(address(this), destinationChain);
        
        messenger.sendMessage(
            destinationChain,
            address(this),
            abi.encodeWithSelector(
                this.recieveEthForArbitrageDestinationChain.selector,
                sendEthMsgHash,
                uint256(block.chainid),
                caller,
                laonAmount,
                flashLoanId
                )
        );
    }

    function recieveEthForArbitrageDestinationChain(bytes32 sendEthMsgHash, uint256 sourceChain, address caller, uint256 loanAmount, bytes32 flashLoanId) 
    external {
        CrossDomainMessageLib.requireCrossDomainCallback();
        CrossDomainMessageLib.requireMessageSuccess(sendEthMsgHash);

        emit soldEth(flashLoanId, address(this).balance, block.chainid, caller);
        executeArbitrage(address(this).balance);
        emit boughtEth(flashLoanId, address(this).balance, block.chainid, caller);

        bytes32 sendEthMsgHashBack = superchainWEth.sendETH{value: address(this).balance}(address(this), sourceChain);
        
        messenger.sendMessage(
            sourceChain,
            address(this),
            abi.encodeWithSelector(
                this.recieveEthOnSourceChainFromDestinationChain.selector,
                sendEthMsgHashBack,
                caller,
                loanAmount,
                flashLoanId
                )
            );
    }

    function recieveEthOnSourceChainFromDestinationChain(bytes32 sendEthMsgHash, address caller, uint256 loanAmount, bytes32 flashLoanId) external{
        CrossDomainMessageLib.requireCrossDomainCallback();
        CrossDomainMessageLib.requireMessageSuccess(sendEthMsgHash);

        int256 profit = int256(address(this).balance) - int256(loanAmount);

        if(profit > 0){
            flashLoanVaultAddress.call {value: loanAmount} ("");
            emit flashLoanRepayed(flashLoanId, loanAmount, block.chainid, caller);
            payable(caller).call {value: address(this).balance} ("");
            emit sentProfit(flashLoanId, uint256(profit), block.chainid, caller);
        }
        else {
            flashLoanVaultAddress.call {value: address(this).balance} ("");
            emit flashLoanRepayed(flashLoanId, loanAmount, block.chainid, caller);
            emit noProfit();
        }
    }

    function initFlashLoan(uint256 destinationChain) public {
        require(destinationChain != block.chainid, "Destination Chain Cannot Be Same As Source Chain");

        uint256 loanAmountRecieved = flashLoanVault.processMaxLoanRequest();
        bytes32 flashLoanId = keccak256(abi.encodePacked( loanAmountRecieved, msg.sender, block.number ));

        emit flashLoanRecieved(flashLoanId, loanAmountRecieved, block.chainid, msg.sender);

        this.recieveEthForArbitrageSourceChain(destinationChain, msg.sender, loanAmountRecieved, flashLoanId);
    }

    receive() external payable{}
}