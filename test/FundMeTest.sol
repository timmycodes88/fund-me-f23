// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinimumUsd() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testDeployerIsOwner() public {
        assertEq(fundMe.i_owner(), address(this));
    }
}
