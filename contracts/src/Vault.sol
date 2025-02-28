// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.26;

// import {IERC20} from "@openzeppelin-contracts/interfaces/IERC20.sol";
// import {ISuperchainTokenBridge} from "@interop-lib/interfaces/ISuperchainTokenBridge.sol";

// interface ICrossDomainMessenger {
//     function xDomainMessageSender() external view returns (address);
//     function sendMessage(
//         address target,
//         bytes calldata message,
//         uint32 gasLimit
//     ) external payable;
// }

// contract FlashLoanVault {

//     address public immutable MESSENGER;

//     constructor(address messenger){
//         MESSENGER = messenger;
//     }

//     receive() external payable {}

//     function send(address handlerContract) public payable {
//         ICrossDomainMessenger(MESSENGER).sendMessage{ value: msg.value }({
//             target: handlerContract,
//             message: "",
//             gasLimit: 200000
//         })
//     }

//     function get_balance() external view returns (uint256) {
//         return address(this).balance;
//     }

//     struct Loan {
//         uint256 amount;
//         address borrower;
//         bool isActive;
//     }

//     // The bridge for cross-chain transfers
//     ISuperchainTokenBridge public constant bridge = ISuperchainTokenBridge(0x4200000000000000000000000000000000000028);

//     // Loan ID => Loan details
//     mapping(bytes32 => Loan) public loans;

//     event LoanCreated(
//         bytes32 indexed loanId, uint256 amount, address borrower
//     );
//     event LoanRepaid(bytes32 indexed loanId, address indexed repayer);
//     event LoanClaimed(bytes32 indexed loanId, address indexed borrower);
//     event LoanReclaimed(bytes32 indexed loanId, address indexed reclaimer);

//     error LoanNotActive();
//     error NotAuthorized();
//     error TransferFailed();
//     error CallFailed();
//     error TimeoutNotElapsed();
//     error InsufficientBalance();

//     function executeFlashLoan(uint256 amount, address borrower) external {
        
//         // Generate loan ID
//         bytes32 loanId = keccak256(abi.encodePacked(amount, borrower));

//         // Store loan details
//         loans[loanId] = Loan({
//             amount: amount,
//             borrower: borrower,
//             isActive: true
//         });

//         emit LoanCreated(loanId, amount, borrower);

//         Loan storage loan = loans[loanId];
//         if (!loan.isActive) revert LoanNotActive();

//         // TODO: Send ETH through the bridge
//         // bytes32 sendERC20MsgHash = bridge.sendERC20(address(0x4200000000000000000000000000000000000024), address(this), amount, destinationChain);

//         // If success, pay the loan
//         loan.isActive = false;
//         emit LoanRepaid(loanId, borrower);

//         // Send remaining ETH to borrower
//         //borrower.transfer(1000)
//     }

// }
