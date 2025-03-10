// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {IFlashBorrower} from "./InterfaceFlashBorrower.sol";
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

    address payable flashBorrowerDefaultAddress;

    address payable superchainWEthAddress = payable(0x4200000000000000000000000000000000000024);
    ISuperchainWETH superchainWEth = ISuperchainWETH(superchainWEthAddress);
    IL2ToL2CrossDomainMessenger public constant messenger =
        IL2ToL2CrossDomainMessenger(0x4200000000000000000000000000000000000023);

    address payable flashLoanVaultAddress;
    FlashLoanVault flashLoanVault;

    constructor(address _flashBorrowerAddress, address _flashLoanVaultAddress) {
        flashLoanVaultAddress = payable(_flashLoanVaultAddress);
        flashLoanVault = FlashLoanVault(flashLoanVaultAddress);
        flashBorrowerDefaultAddress = payable(_flashBorrowerAddress);
    }

    function recieveEthForArbitrageSourceChain(uint256 destinationChain, address caller, uint256 laonAmount, bytes32 flashLoanId, address payable flashBorrower) 
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
                flashLoanId,
                flashBorrower
                )
        );
    }

    function recieveEthForArbitrageDestinationChain(bytes32 sendEthMsgHash, uint256 sourceChain, address caller, uint256 loanAmount, bytes32 flashLoanId, address payable flashBorrower) 
    external {
        CrossDomainMessageLib.requireCrossDomainCallback();
        CrossDomainMessageLib.requireMessageSuccess(sendEthMsgHash);

        uint256 ethAmount = address(this).balance;

        try IFlashBorrower(flashBorrower).onFlashLoan{value: ethAmount}(ethAmount, address(this)){
            emit soldEth(flashLoanId, address(this).balance, block.chainid, caller);
        } catch {
            // TODO: Handle Paying Back Loan!
            revert ("onFlashLoan Function Failed");
        }

        if (address(this).balance < ethAmount){
            // TODO: Handle Paying Back Loan!
            revert ("Sufficient Funds Were Not Returned");
        } 

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

    function initFlashLoan(uint256 destinationChain, address payable flashBorrower, address caller) public {
        require(destinationChain != block.chainid, "Destination Chain Cannot Be Same As Source Chain");

        uint256 loanAmountRecieved = flashLoanVault.processMaxLoanRequest();
        bytes32 flashLoanId = keccak256(abi.encodePacked( loanAmountRecieved, caller, block.number ));

        emit flashLoanRecieved(flashLoanId, loanAmountRecieved, block.chainid, caller);

        this.recieveEthForArbitrageSourceChain(destinationChain, caller, loanAmountRecieved, flashLoanId, flashBorrower);
    }

    function callFlashLoanHandler(uint256 destinationChain) public {
        this.initFlashLoan(destinationChain, flashBorrowerDefaultAddress, msg.sender);
    }
    function callFlashLoanHandlerAdvanced(uint256 destinationChain, address flashBorrowerAddress) public {
        this.initFlashLoan(destinationChain, payable(flashBorrowerAddress), msg.sender);
    }

    receive() external payable{}
}