pragma solidity ^0.8.28;

contract FlashLoanVault {

    uint256 maxFlashLoanPercent = 1000; // 10%

    function processLoanRequest(uint256 amountRequested) public returns (bool){

        uint256 vaultEthLiquidity = address(this).balance;

        if ( amountRequested > vaultEthLiquidity * maxFlashLoanPercent / 10000) {
            payable(msg.sender).call {value : amountRequested} ("");
            return true; // Flash Loan Succeeds
        }

        else {
            return false; // Flash Loan Fails
        }
        
    }

    function processMaxLoanRequest() public returns (uint256){
        uint256 vaultEthLiquidity = address(this).balance * maxFlashLoanPercent / 10000;
        payable(msg.sender).call {value : vaultEthLiquidity} ("");
        return vaultEthLiquidity;
    }

    receive() external payable{}
}