// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {WETH} from "../src/token.sol";

contract WrappedTokenTest is Test {
    WETH public weth;

    function setUp() public {
        weth = new WETH();
    }

}