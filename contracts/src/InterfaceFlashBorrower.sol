// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IFlashBorrower {
    /**
     * @param amount The amount of tokens lent.
     * @param flashLoanHandlerAddress the address of the flashLoanHandler contract.
     */
    function onFlashLoan(uint256 amount, address flashLoanHandlerAddress) external payable;

    receive() external payable{}
}