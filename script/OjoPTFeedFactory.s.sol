// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "../src/OjoPTFeedFactory.sol";
import "../src/OjoPTFeed.sol";

contract DeployOjoPTFeedFactory is Script {
    function run() external {
        vm.startBroadcast();

        OjoPTFeedFactory factory = new OjoPTFeedFactory();

        console.log("OjoPTFeedFactory deployed at:", address(factory));

        vm.stopBroadcast();
    }
}

contract CreateOjoPTFeed is Script {
    function run() external {
        address ojoPTFeedFactory = vm.envAddress("OJO_PT_FEED_FACTORY");
        address FEED_1 = vm.envAddress("FEED_1");
        address FEED_2 = vm.envAddress("FEED_2");

        vm.startBroadcast();

        OjoPTFeedFactory factory = OjoPTFeedFactory(ojoPTFeedFactory);

        address feed = factory.createOjoPTFeed(FEED_1, FEED_2);

        console.log("New OjoPTFeed created at:", feed);

        vm.stopBroadcast();
    }
}
