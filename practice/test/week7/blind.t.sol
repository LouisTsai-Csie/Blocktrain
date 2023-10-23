// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {BlindNFT} from "../../src/week7/blind.sol";

contract BlindNFTTest is Test {
    address owner;
    BlindNFT public blindNFT;
    
    function setUp() public {
        owner = makeAddr("owner");
        vm.startPrank(owner);
        blindNFT = new BlindNFT();
        vm.stopPrank();
    }

    function test_adminSetAuctionStartTime() public {
        uint256 timestamp = 1641070800;
        vm.startPrank(owner);
        vm.warp(timestamp);
        blindNFT.setAuctionStartTime(timestamp);
        assertEq(blindNFT.auctionStartTime(), timestamp);
        vm.stopPrank();
    }

    function test_notAdminSetAuctionStartTime() public {
        uint256 timestamp = 1641070800;
        address user = makeAddr("user");
        vm.startPrank(user);
        vm.warp(timestamp);
        vm.expectRevert();
        blindNFT.setAuctionStartTime(timestamp);
        vm.stopPrank();
    }

    function test_getAuctionPriceBeforeAuction() public {
        uint256 auctionStartTimestamp = 1641070800;
        vm.prank(owner);
        blindNFT.setAuctionStartTime(auctionStartTimestamp);
    
        uint256 currentTimestamp = auctionStartTimestamp - 1 minutes;
        vm.warp(currentTimestamp);
        address user = makeAddr("user");
        vm.prank(user);
        uint256 auctionPrice = blindNFT.getAuctionPrice();
        assertEq(auctionPrice, 1 ether);
    }

    function test_getAuctionPriceAfterAuction() public {
        uint256 auctionStartTimestamp = 1641070800;
        vm.prank(owner);
        blindNFT.setAuctionStartTime(auctionStartTimestamp);
        uint256 currentTimestamp = auctionStartTimestamp + 1 weeks;
        vm.warp(currentTimestamp);
        address user = makeAddr("user");
        vm.prank(user);
        uint256 auctionPrice = blindNFT.getAuctionPrice();
        assertEq(auctionPrice, 0.1 ether);
    }

    function test_getAuctionPriceDuringAuction() public {
        uint256 auctionStartTimestamp = 1641070800;
        vm.prank(owner);
        blindNFT.setAuctionStartTime(auctionStartTimestamp);
        uint256 currentTimestamp = auctionStartTimestamp + 10 seconds;
        vm.warp(currentTimestamp);
        address user = makeAddr("user");
        vm.prank(user);
        uint256 auctionPrice = blindNFT.getAuctionPrice();
        console2.log(auctionPrice);
        assertEq(auctionPrice, 985000000000000000);
    }
    
}