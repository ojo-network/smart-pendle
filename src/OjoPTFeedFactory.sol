// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./OjoPTFeed.sol";

contract OjoPTFeedFactory {
    using Clones for address;

    address public immutable implementation;
    mapping(address => address) public OjoPTFeedAddresses;

    event OjoPTFeedCreated(address indexed feed);

    constructor() {
        implementation = address(new OjoPTFeed());
    }

    function createOjoPTFeed(address FEED_1, address FEED_2) external returns (address FEED) {
        FEED = implementation.clone();
        OjoPTFeed(FEED).initialize(FEED_1, FEED_2);
        OjoPTFeedAddresses[msg.sender] = FEED;
        emit OjoPTFeedCreated(FEED);
    }
}
