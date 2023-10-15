// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20{

    event  DepositEvent(address indexed addr, uint256 amount);
    event  WithdrawalEvent(address indexed addr, uint256 amount);

    constructor() ERC20("WETH", "WETH"){
    }

    fallback() external payable {
        deposit();
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit DepositEvent(msg.sender, msg.value);
    }

    function withdraw(uint amount) public {
        require(balanceOf(msg.sender) >= amount, "insufficient token balance amount");
        _burn(msg.sender, amount);
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "transfer failed");
        emit WithdrawalEvent(msg.sender, amount);
    }
}