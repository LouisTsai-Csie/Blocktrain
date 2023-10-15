// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {WETH} from "../src/token.sol";

contract WrappedTokenTest is Test {
    WETH public weth;

    function setUp() public {
        weth = new WETH();
    }

    function test_DepositTokenAmountEqualMintAmount() public {
        // create user account
        address user = makeAddr("user");
        // set user address for the following function call
        vm.startPrank(user);
        // set ether balance for user
        deal(user, 1 ether);
        // user deposit 1 ether balance to the contract
        weth.deposit{value: 1 ether}();
        // check ERC20 balance for user
        uint256 receiveERC20Amount = weth.balanceOf(user);
        // compare user ERC20 token amount and sent ether amount
        assertEq(receiveERC20Amount, 1 ether);
        // stop prank and exit the test
        vm.stopPrank();
    }

    function test_DepositTokenAmountEqualReceiveEtherBalance() public {
        // create user account
        address user = makeAddr("user");
        // set user address for the following function call
        vm.startPrank(user);
        // set ether balance for user
        deal(user, 1 wei);
        // user ether balance before deposit operation
        uint256 originalEthAmount = payable(weth).balance;
        // user deposit 1 ether balance to the contract
        weth.deposit{value: 1 wei}();
        // total ether balance of user after deposit operation
        uint256 totalEthAmount = payable(weth).balance;
        // calculate ether balance difference
        uint256 receiveEthAmount = totalEthAmount - originalEthAmount;
        // check deposit token amount balance and receive ether balance
        assertEq(receiveEthAmount, 1 wei);
        // stop prank and exit the test
        vm.stopPrank();
    }

}