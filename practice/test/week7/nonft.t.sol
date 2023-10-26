// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Nonsense, HW_Token, NFTReceiver} from "../../src/week7/nonft.sol";

contract NFTReceiverTest is Test {
    Nonsense public nonsense;
    HW_Token public hwToken;
    NFTReceiver public nftReceiver;
    
    function setUp() public {
        // setup Nonse token instance
        nonsense = new Nonsense();
        // setup HW_Token token instance
        hwToken  = new HW_Token();
        // setup NFTReceiver Token instance
        nftReceiver = new NFTReceiver(address(hwToken));
    }

    // Verify the minting function operates correctly for nonsense NFT token
    // Check the tokenId value increase corresponding to the minting function
    function test_nonsenseMintNFT() public {
        address user = makeAddr("user");
        vm.startPrank(user);
        uint256 tokenId = nonsense.mint(user);
        assertEq(tokenId, 0);
        vm.stopPrank();
    }

    // Verify the minting function operates correctly for nonsense NFT token
    // Check the user balance and token owner corrsponding to the minting function  
    function test_nonsenseReceiveNFT() public {
        address user = makeAddr("user");
        vm.startPrank(user);
        nonsense.mint(user);
        assertEq(nonsense.balanceOf(user), 1);
        assertEq(nonsense.ownerOf(0), user);
        vm.stopPrank();
    }

    // Verify the minting function operates correctly for homework NFT token
    // Check the tokenId value increase corresponding to the minting function
    function test_hwTokenMintNFT() public {
        address user = makeAddr("user");
        vm.startPrank(user);
        uint256 tokenId = hwToken.mint(user);
        assertEq(tokenId, 0);
        vm.stopPrank();
    }

    // Verify the minting function operates correctly for homework NFT token
    // Check the user balance and token owner corrsponding to the minting function  
    function test_hwTokenReceiveNFT() public {
        address user = makeAddr("user");
        vm.startPrank(user);
        hwToken.mint(user);
        assertEq(hwToken.balanceOf(user), 1);
        assertEq(hwToken.ownerOf(0), user);
        vm.stopPrank();
    }

    // Verify the hwToken NFT returns the correct URI.
    function test_hwTokenURI() public {
        string memory uri = "https://yellow-similar-roadrunner-408.mypinata.cloud/ipfs/QmVmKb6j5dcdFRM5cxtsgukSka48uKCdZRy9vSHrtm2XQG?_gl=1*ea76s5*_ga*MTMzNTkyNjAzMS4xNjk3NzE2NTY2*_ga_5RMPXG14TE*MTY5Nzk4NTgwMi4yLjEuMTY5Nzk4NTg0Ny4xNS4wLjA.";
        address user = makeAddr("user");
        vm.startPrank(user);
        uint256 tokenId = hwToken.mint(user);
        string memory receiveTokenURI = hwToken.tokenURI(tokenId);
        assertEq(uri, receiveTokenURI);
    }
    
    // Send hwToken to NFTReceiver and check the contract receive the NFT correctly
    // Verify the NFTReceiver balance and hwToken NFT owner corresponding to the transfer
    function test_NFTReceiverGetHWToken() public {
        address user = makeAddr("user");
        vm.startPrank(user);
        uint256 tokenId = hwToken.mint(user);
        hwToken.safeTransferFrom(user, address(nftReceiver), tokenId);
        assertEq(hwToken.balanceOf(address(nftReceiver)), 1);
        assertEq(hwToken.ownerOf(tokenId), address(nftReceiver));
        vm.stopPrank();
    }

    // Send nonsense NFT to NFTReceiver and check the contract returns the NFT correctly
    // Verify the user balance and nonsense NFT owner corresponding to the transfer
    function test_NFTReceiverGetNonsenseTokenBack() public {
        address user = makeAddr("user");
        vm.startPrank(user);
        uint256 tokenId = nonsense.mint(user);
        nonsense.safeTransferFrom(user, address(nftReceiver), tokenId);
        assertEq(nonsense.balanceOf(user), 1);
        assertEq(nonsense.ownerOf(tokenId), user);
        vm.stopPrank();
    }

    // Send nonsense NFT to NFTReceiver and check the contract mint the hwToken NFT correctly
    // Verify the user balance and hwToken NFT owner corresponding to the transfer.
    function test_NFTReceiverGetHWTokenFromMistransfer() public {
        address user = makeAddr("user");
        vm.startPrank(user);
        uint256 tokenId = nonsense.mint(user);
        nonsense.safeTransferFrom(user, address(nftReceiver), tokenId);
        assertEq(hwToken.balanceOf(address(user)), 1);
        assertEq(hwToken.ownerOf(0), address(user));
        assertEq(hwToken.balanceOf(address(nftReceiver)), 0);
        vm.stopPrank();
    }
}