// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {WETH} from "../../src/week6/token.sol";

interface IWETHEvents {
    event DepositEvent(address indexed addr, uint256 amount);
    event WithdrawalEvent(address indexed addr, uint256 amount);
}

contract WrappedTokenTest is IWETHEvents, Test {
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

    function test_CheckDepositEventEmitSuccess() public {
        // create user account
        address user = makeAddr("user");
        // set user address for the following function call
        vm.startPrank(user);
        // set ether balance for user
        deal(user, 1 ether);
        // expected verification format, topic 1 and data field
        vm.expectEmit(true, false, false, true);
        // emit the desired deposit event result
        emit DepositEvent(user, 1 ether);
        // make deposit function and check event result
        weth.deposit{value: 1 ether}();
        // stop prank and exit the test
        vm.stopPrank();
    }

    function test_WithdrawBurnTokenAmountEqualInputAmount() public {
        // create user account
        address user = makeAddr("user");
        // set user address for the following function call
        vm.startPrank(user);
        // set ether balance for user
        deal(user, 1 ether);
        // user deposit 1 ether balance to the contract
        weth.deposit{value: 1 ether}();
        // configure burning ether amount
        uint256 burnAmount = 1;
        // check original ERC20 token amount before withdraw operation
        uint256 originalERC20Amount = weth.balanceOf(user);
        // perform withdraw with burnAmount as parameter
        weth.withdraw(burnAmount);
        // check the total ERC20 token amount after withdraw operation
        uint256 totalERC20Amount = weth.balanceOf(user);
        // check the burning ERC20 token amount after withdraw operation
        uint256 burnERC20Amount = originalERC20Amount - totalERC20Amount;
        // check the equivalence of burnAmount and burnERC20AMount
        assertEq(burnAmount, burnERC20Amount);
        // stop prank and exit the test
        vm.stopPrank();
    }

    function test_WithdrawTokenAmountEqualReceiveEtherAmount() public {
        // create user account
        address user = makeAddr("user");
        // set user address for the following function call
        vm.startPrank(user);
        // set ether balance for user
        deal(user, 1 ether);
        // user deposit 1 ether balance to the contract
        weth.deposit{value: 1 ether}();
        // check the user ether balance after deposit
        uint256 depositUserEtherBalance = payable(user).balance;
        // check the contract ether balance after deposit
        uint256 depositContractEtherBalance = payable(weth).balance;
        // perform withdraw for 1 ether
        weth.withdraw(1 ether);
        // check total user ether balance after withdrawal
        uint256 totalUserEtherBalance = payable(user).balance;
        // check total contract ether balance after withdrawal
        uint256 totalContractEtherBalance = payable(weth).balance;
        // validate the user balance difference
        assertEq(totalUserEtherBalance - depositUserEtherBalance, 1 ether);
        // validate the contract balance difference
        assertEq(depositContractEtherBalance - totalContractEtherBalance, 1 ether);
        // stop prank and exit the test
        vm.stopPrank();
    }

    function test_CheckWithdrawEventEmitSuccess() public {
        // create user account
        address user = makeAddr("user");
        // set user address for the following function call
        vm.startPrank(user);
        // set ether balance for user
        deal(user, 1 ether);
        // user deposit 1 ether balance to the contract
        weth.deposit{value: 1 ether}();
        // expected verification format, topic 1 and data field
        vm.expectEmit(true, false, false, false);
        // emit the desired withdraw event result
        emit WithdrawalEvent(user, 1 ether);
        // make withdraw function and check event result
        weth.withdraw(1);
        // stop prank and exit the test
        vm.stopPrank();
    }

    function test_ValidateTransferTokenAmount() public {
        // create user1 account
        address user1 = makeAddr("user1");
        // create user2 account
        address user2 = makeAddr("user2");
        // set user address for the following function call
        vm.startPrank(user1);
        // set ether balance for user
        deal(user1, 1 ether);
        // user deposit 1 ether balance to the contract
        weth.deposit{value: 1 ether}();
        // check user1 original ERC20 balance before token transfer
        uint256 user1OriginalERC20Amount = weth.balanceOf(user1);
        // check user2 original ERC20 balance before token transfer
        uint256 user2OriginalERC20Amount = weth.balanceOf(user2);
        // transfer ERC20 token from user1 to user 2
        weth.transfer(user2, 1);
        // check user1 total ERC20 balance after token transfer
        uint256 user1TotakERC20Amount = weth.balanceOf(user1);
        // check user 2 total ERC20 balance after token transfer
        uint256 user2TokenERC20Amount = weth.balanceOf(user2);
        // assert the transfer amount for user1
        assertEq(user1OriginalERC20Amount - user1TotakERC20Amount, 1);
        // assert the transfer amount for user2
        assertEq(user2TokenERC20Amount - user2OriginalERC20Amount, 1);
        // stop prank and exit the test
        vm.stopPrank();
    }

    function test_ValidateApproveTokenAmount() public {
        // create user1 account
        address user1 = makeAddr("user1");
        // create user2 account
        address user2 = makeAddr("user2");
        // set user address for the following function call
        vm.startPrank(user1);
        // check user1 original allowance for user2
        uint256 user2OriginalAllowance = weth.allowance(user1, user2);
        // set ether balance for user
        deal(user1, 1 ether);
        // user1 deposit 1 ether balance to the contract
        weth.deposit{value: 1 ether}();
        // user1 approve ether for user2
        weth.approve(user2, 1 ether);
        // check user2 approve allowance for user2
        uint256 user2ApproveAllowance = weth.allowance(user1, user2);
        // assert the user1 allowance amount for user2
        assertEq(user2ApproveAllowance - user2OriginalAllowance, 1 ether);
        // stop prank and exit the test
        vm.stopPrank();
    }

    function test_ValidateERC20TransferFrom() public {
        // create user1 account
        address user1 = makeAddr("user1");
        // create user2 account
        address user2 = makeAddr("user2");
        // create user3 account
        address user3 = makeAddr("user3");
        // set user1 address for the following function call
        vm.startPrank(user1);
        // set ether balance for user1
        deal(user1, 1 ether);
        // user1 deposit 1 ether balance to the contract and get ERC20 token
        weth.deposit{value: 1 ether}();
        // user1 approve ERC20 token allowance for user2
        weth.approve(user2, 1 ether);
        // set user2 address for the following function call
        vm.startPrank(user2);
        // transfer token from user1 to user3 based on the user2 token allowance
        bool success = weth.transferFrom(user1, user3, 1 ether);
        // assert the transferFrom result to be successful
        assertEq(success, true);
        // stop prank and exit the test
        vm.stopPrank();
    }

    function test_validateERC20TransferFromAllowanceChange() public {
        // create user1 account
        address user1 = makeAddr("user1");
        // create user2 account
        address user2 = makeAddr("user2");
        // create user3 account
        address user3 = makeAddr("user3");
        // set user1 address for the following function call
        vm.startPrank(user1);
        // set ether balance for user1
        deal(user1, 1 ether);
        // user1 deposit 1 ether balance to the contract and get ERC20 token
        weth.deposit{value: 1 ether}();
        // user1 approve ERC20 token allowance for user2
        weth.approve(user2, 1 ether);
        // check the original user1 token allowance for user2, that is allowance[user1][user2]
        uint256 originalERC20TokenAllowance = weth.allowance(user1, user2);
        // validate the user1 allowance amount after approve operation
        assertEq(originalERC20TokenAllowance, 1 ether);
        // set user2 address for the following function call
        vm.startPrank(user2);
        // transfer token from user1 to user3 based on the user2 token allowance
        bool success = weth.transferFrom(user1, user3, 1 ether);
        // assert the transferFrom result to be successful
        assertEq(success, true);
        // check the user1 token allowance after transferFrom operation
        uint256 transferERC20TokenAllowance = weth.allowance(user1, user2);
        // validate the uaser1 allowance amount after transferFrom operation
        assertEq(transferERC20TokenAllowance, 0);
        // stop prank and exit the test
        vm.stopPrank();
    }
}
