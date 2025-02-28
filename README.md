# superchain-interop-flashloans

This Repo was used as a Guide: [superchain-starter-xchain-flash-loan-example](https://github.com/ethereum-optimism/superchain-starter-xchain-flash-loan-example/blob/main/README.md)  

The Following Example Provides a FrontEnd built on React.js and ether.js. Instead of viem or wagmi  

## Example Superchain app (contract + frontend)  
This app uses interop to flash loan ERC20s between chains.  

<p align="center">
  <img src="https://github.com/user-attachments/assets/00cb1565-530a-42e5-8163-edb883483390" width="200">
  <img src="https://github.com/user-attachments/assets/b1be8a63-8364-41e7-8134-1cacd4d79f5e" width="200">
  <img src="https://github.com/user-attachments/assets/f245a645-49c5-4ed8-bca7-885bd0c95365" width="200">
</p>

## 📝 Overview

This project implements a cross-chain flash loan system that allows users to borrow tokens on one chain and use them on another chain. Here's how it works:
## Detailed Description of Each Contract in the Superchain Flash Loan System

## 🔗 Contracts

  ### [CrosschainFlashLoanBridge.sol]( )
  ### [FlashLoanVault.sol]( )
  ### [FrontEnd Main Contract]( )
  ### [TargetContract.sol]( )
  ### [FlashLoanHandler.sol](https://github.com/aaryan-gulia/superchain-interop-flashloans/blob/main/contracts/src/FlashLoanHandler.sol)
  
## 1. Frontend Contract (Main Contract)
### Purpose:
- Acts as the entry point for users to interact with the flash loan system.
- Handles user requests, such as borrowing ETH for arbitrage as it communicates with the FlashloanVaultContract
- Manages loan repayment and profit distribution. 

---

## 2. Flash Loan Vault
### Purpose:
- Provides ETH liquidity for flash loans.
- Verifies loan requests and ensures availability.
- Works with the **IOP - Bridge Interoperability** to send ETH cross-chain over to chain B
-  Notifies the **Main Contract** that funds have returned.
  
---

## 3. IOP - Bridge Interoperability
### Purpose:
- Handles cross-chain transfers of ETH.
- Ensures safe and secure bridging of assets between Chain A and Chain B.
- Communicates with the FlashLoan Vault to Repay the ETH.
- Receives ETH back from Chain B after arbitrage and Communicates with the FlashLoan Vault

---

## 4. Flash Loan Handler
### Purpose:
- Receives ETH to Chain B for arbitrage execution.
- Calls the Dummy contract on Chain B to notify about the incoming funds.
- Verifies execution flow and ensures all steps are completed properly.
- Checks that the borrowed amount has been used and repaid correctly.
- Manages risk by enforcing loan rules.
- Ensures arbitrage was completed successfully.
- Checks if the **Dummy Contract** has returned ETH.

---

## 5. Dummy Contract (Arbitrage Execution)
### Purpose:
- Executes the arbitrage trade between DEXs on Chain B for Now this Contract Simulates an Arbitrage as if it was in a DEX.
- Returns ETH to the **Flash Loan Handler**
- Executes the arbitrage logic (buy/sell to make a profit).

---

## 6. Transaction Completion
### Final Steps:
1. **Dummy Contract sends ETH back to the FlashLoanHandler**
2. **Flash Loan Handler verifies that the process was successful.**
3. **Flash loan Handler communicates with the IOP-Bridge, Bridges Funds over at the FlashLoan Vault and repays the Loan.**
4. **Flash Loan Vault communicates with the Main Contract and repays the ETH.**
5. **Flash Loan Vault  transfers remaining ETH profit to the user’s wallet.**

---

### Final Overview of Contract Interactions
1. **User → Main Contract** (Requests Flash Loan)
2. **Main Contract → Flash Loan Vault** (Borrows ETH)
3. **Vault → IOP Bridge** (Bridges ETH to Chain B)
4. **IOP Bridge → FlashLoanHandler** (Receives ETH)
5. **Flash Loan Handler → Dummy Contract**(Executes Arbitrage)
6. **Dummy Contract → FlashLoanHandler** (Returns Arbitrage ETH)
7. **FlashLoanHandler → IOP Bridge** → **FlashLoanVault**(Bridges ETH back and Pays it in the Vault)
8.**FlashLoanVault → Main Contracts** (Repaying ETH) 
9. **Main Contract → User** (Sends Profit)






