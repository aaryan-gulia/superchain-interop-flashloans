// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestUSDToken is ERC20 {
    constructor() ERC20("TestUSDToken", "TUSD") {
        //_mint(msg.sender, 1000000 * 10 ** decimals()); // Mint 1,000,000 TUSD to deployer
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
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

        require(address(this).balance > finalEthAmount, "Not enough ETH in contract");
    
        token.transferFrom(msg.sender, address(this), tusdAmount);
        receivingAddress.transfer(finalEthAmount);
    }


}