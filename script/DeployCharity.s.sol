// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {CharityDonation} from "../src/Charityfunding.sol";

contract DeployCharity is Script {
    function run() public returns (CharityDonation) {
        vm.startBroadcast();
        CharityDonation charitydonation = new CharityDonation();
        vm.stopBroadcast();
        return charitydonation;
    }
}
