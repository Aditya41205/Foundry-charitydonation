// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {CharityDonation} from "../src/Charityfunding.sol";

contract testCharity is Test {
    // Variables
    uint256 public constant DONOR_BALANCE = 100 ether;
    uint256 public constant MINIMUM_DONATION = 0.01 ether;
    address public Donor = makeAddr("Donor");
    address public CharityOwner = makeAddr("CharityOwner");
    address public charityAddress = makeAddr("CharityAddress");
    CharityDonation public charitydonation;

   
    event DONATOR(uint256 amount, address sender);

    // Setup function
    function setUp() external {
        vm.prank(CharityOwner); // Deploy the contract from CharityOwner's address
        charitydonation = new CharityDonation();
        vm.deal(Donor, DONOR_BALANCE); // Fund the Donor's address with 100 ether
    }

    // Test that the owner is set correctly upon deployment
    function testOwnerIsSetCorrectly() public {
        address contractOwner = charitydonation.owner();
        assertEq(CharityOwner, contractOwner, "Owner should be the CharityOwner");
    }

    // Test that only the owner can call sendtocharity function
    function testOnlyOwnerCanSendToCharity() public {
        vm.startPrank(Donor);
        vm.expectRevert("ONLY OWNER CAN WITHDRAW");
        charitydonation.sendtocharity(charityAddress); // Attempt to call by a non-owner
        vm.stopPrank();

        vm.startPrank(CharityOwner);
        vm.deal(address(charitydonation), 1 ether); // Fund the contract
        charitydonation.sendtocharity(charityAddress); // Call by the owner, should succeed
        vm.stopPrank();
    }

    // Test for funding the contract
    function testFunding() public {
        vm.startPrank(Donor);

        // Send enough Ether to fund
        vm.expectEmit(true, true, false, true);
        emit DONATOR(MINIMUM_DONATION, Donor); // Emitting expected event for the test
        charitydonation.fund{value: MINIMUM_DONATION}("Alice", "Great cause!");

(uint256 amount, string memory name, string memory feedback)= charitydonation.donorinfo(Donor);

    assertEq(amount, MINIMUM_DONATION, "Donation amount should match");
        assertEq(name, "Alice", "Donor name should match");
        assertEq(feedback, "Great cause!", "Donor feedback should match");

        // Test insufficient fund error
        vm.expectRevert("Give enough eth");
        charitydonation.fund{value: MINIMUM_DONATION - 0.001 ether}("Bob", "Not enough Ether");

        vm.stopPrank();
    }

    // Test for sending funds to charity
    function testSendToCharity() public {
        vm.startPrank(Donor);
        charitydonation.fund{value: 1 ether}("Alice", "Supporting the cause!"); //1ether
        vm.stopPrank();

        vm.startPrank(CharityOwner);
        uint256 charityBalanceBefore = charityAddress.balance;
        charitydonation.sendtocharity(charityAddress); // Only the owner can call this
        uint256 charityBalanceAfter = charityAddress.balance;

        assertEq(
            charityBalanceAfter - charityBalanceBefore,
            "Charity should receive the entire contract balance"
        );
        vm.stopPrank();
    }

    // Test donation time has expired
    function testFundAfterDonationTimeExpired() public {
        vm.startPrank(Donor);
        // Increase time to beyond the donation period
        vm.warp(block.timestamp + 8 days);
        vm.expectRevert("Donating time is over");
        charitydonation.fund{value: MINIMUM_DONATION}("Alice", "Time expired donation");

        vm.stopPrank();
    }
}
