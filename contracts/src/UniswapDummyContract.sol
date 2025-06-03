// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { IERC7802, IERC165 } from "@interop-lib/interfaces/IERC7802.sol";
import {PredeployAddresses} from "@interop-lib/libraries/PredeployAddresses.sol";

contract TestUSDToken is IERC7802, ERC20 {
    constructor() ERC20("TestUSDToken", "TUSD") {
        //_mint(msg.sender, 1000000 * 10 ** decimals()); // Mint 1,000,000 TUSD to deployer
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    /// @notice Allows the SuperchainTokenBridge to mint tokens.
    /// @param _to     Address to mint tokens to.
    /// @param _amount Amount of tokens to mint.
    function crosschainMint(address _to, uint256 _amount) external {
        // Only the `SuperchainTokenBridge` has permissions to mint tokens during crosschain transfers.
        require(msg.sender == PredeployAddresses.SUPERCHAIN_TOKEN_BRIDGE, "Unauthorized");

        // Mint tokens to the `_to` account's balance.
        _mint(_to, _amount);

        // Emit the CrosschainMint event included on IERC7802 for tracking token mints associated with cross chain transfers.
        emit CrosschainMint(_to, _amount, msg.sender);
    }

    /// @notice Allows the SuperchainTokenBridge to burn tokens.
    /// @param _from   Address to burn tokens from.
    /// @param _amount Amount of tokens to burn.
    function crosschainBurn(address _from, uint256 _amount) external {
        // Only the `SuperchainTokenBridge` has permissions to burn tokens during crosschain transfers.
        require(msg.sender == PredeployAddresses.SUPERCHAIN_TOKEN_BRIDGE, "Unauthorized");

        // Burn the tokens from the `_from` account's balance.
        _burn(_from, _amount);

        // Emit the CrosschainBurn event included on IERC7802 for tracking token burns associated with cross chain transfers.
        emit CrosschainBurn(_from, _amount, msg.sender);
    }

    /// @notice Query if a contract implements an interface
    /// @param _interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    /// uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    /// `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 _interfaceId) public view virtual returns (bool) {
        return _interfaceId == type(IERC7802).interfaceId || _interfaceId == type(IERC20).interfaceId
            || _interfaceId == type(IERC165).interfaceId;
    }
}

contract UniswapDummyContract {

    TestUSDToken public token;
    uint256 public minAmount = 0;

    // TODO: get price of eth in USDC from chainlink
    uint256 public price_eth_in_usdc = 2500;

    // TODO: expected premium to identify
    uint256 public premium_percent = 300; //3 percent

    // function fund () {

    // }
    constructor(TestUSDToken _token) {
        token = _token;
        token.mint(address(this), 100_000_000_000 ether);
    }
    

    function getEthPrice (uint256 amountToken0) public view returns (uint256) {

        // require(token0 == wethToken, "This is not the token you're looking for");
        // require(token1 == usdToken, "This is not a USDC Token");

        uint256 value = amountToken0*price_eth_in_usdc*premium_percent/10000;

        return value;
    }

    function sellEth () public payable {
        require(msg.value > 0, "Send ETH to receive tokens");
        
        uint256 tokenAmount = msg.value * price_eth_in_usdc;
        
        token.transfer(msg.sender, tokenAmount);
    }

    function buyEth(address payable receivingAddress, uint256 tusdAmount) public {
        require(tusdAmount > 0, "Send TUSD to receive ETH");

        uint256 ethAmount = tusdAmount / price_eth_in_usdc;
        uint256 finalEthAmount = ethAmount + ((ethAmount * premium_percent) / 10000);

        require(address(this).balance >= finalEthAmount, "Not enough ETH in contract");
    
        token.transferFrom(msg.sender, address(this), tusdAmount);
        receivingAddress.transfer(finalEthAmount);
    }

    function getToken() public view returns  (TestUSDToken){
        return token;
    }

    receive() external payable{}

}