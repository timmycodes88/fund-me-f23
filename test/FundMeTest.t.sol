// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address user = makeAddr("user");

    uint256 constant TEN_ETH = 10 ether;

    uint256 constant STARTING_ETH_DEAL = 1000 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(user, STARTING_ETH_DEAL);
    }

    function testMinimumUsd() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testDeployerIsOwner() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundRevertsIfLessThanMinimumUsd() public {
        vm.expectRevert();
        vm.prank(user);
        fundMe.fund{value: 0}();
    }

    modifier funded() {
        vm.prank(user);
        fundMe.fund{value: TEN_ETH}();
        _;
    }

    function testFundUpdatesData() public funded {
        assertEq(fundMe.getAmountFundedFromAddress(user), TEN_ETH);
        assertEq(fundMe.getFunder(0), user);
    }

    function testNonOwnerCanNotWithdraw() public funded {
        vm.expectRevert();
        vm.prank(user);
        fundMe.withdraw();
    }

    function testWithdrawByOwner() public funded {
        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 contractStartingBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 ownerEndingBalance = fundMe.getOwner().balance;
        uint256 contractEndingBalance = address(fundMe).balance;
        assertEq(
            ownerEndingBalance,
            ownerStartingBalance + contractStartingBalance
        );
        assertEq(contractEndingBalance, 0);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), TEN_ETH);
            fundMe.fund{value: TEN_ETH}();
        }

        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 contractStartingBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 ownerEndingBalance = fundMe.getOwner().balance;
        uint256 contractEndingBalance = address(fundMe).balance;

        assertEq(
            ownerEndingBalance,
            ownerStartingBalance + contractStartingBalance
        );
        assertEq(contractEndingBalance, 0);
    }

    function testCheaperWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), TEN_ETH);
            fundMe.fund{value: TEN_ETH}();
        }

        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 contractStartingBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        uint256 ownerEndingBalance = fundMe.getOwner().balance;
        uint256 contractEndingBalance = address(fundMe).balance;

        assertEq(
            ownerEndingBalance,
            ownerStartingBalance + contractStartingBalance
        );
        assertEq(contractEndingBalance, 0);
    }
}
