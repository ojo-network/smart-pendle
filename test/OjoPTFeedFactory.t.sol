// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Test.sol";
import "../src/OjoPTFeed.sol";
import "../src/OjoPTFeedFactory.sol";
import "./MockPriceFeed.sol";

contract OjoPTFeedTest is Test {
    OjoPTFeed public ojoPTFeed;
    OjoPTFeedFactory public factory;
    MockPriceFeed public feed1;
    MockPriceFeed public feed2;

    int256 constant INITIAL_PRICE_FEED1 = 1e18;
    int256 constant INITIAL_PRICE_FEED2 = 12e17;
    uint8 constant DECIMALS = 18;
    string constant DESCRIPTION = "ETH / USD";
    uint256 constant VERSION = 1;

    function setUp() public {
        feed1 = new MockPriceFeed(INITIAL_PRICE_FEED1, DECIMALS, DESCRIPTION, VERSION);

        feed2 = new MockPriceFeed(INITIAL_PRICE_FEED2, DECIMALS, DESCRIPTION, VERSION);

        factory = new OjoPTFeedFactory();
        address feedAddress = factory.createOjoPTFeed(address(feed1), address(feed2));
        ojoPTFeed = OjoPTFeed(feedAddress);
    }

    function testDescription() public {
        string memory description = ojoPTFeed.description();
        assertEq(description, "Ojo PT Feed ETH / USD");
    }

    function testLatestRoundDataReturnsLowerPrice() public {
        // Get the latest round data from OjoPTFeed
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            ojoPTFeed.latestRoundData();

        // Get data from individual feeds for comparison
        (uint80 roundId1, int256 answer1, uint256 startedAt1, uint256 updatedAt1, uint80 answeredInRound1) =
            feed1.latestRoundData();

        (uint80 roundId2, int256 answer2, uint256 startedAt2, uint256 updatedAt2, uint80 answeredInRound2) =
            feed2.latestRoundData();

        // Verify that OjoPTFeed returns the lower price (feed1 in this case)
        assertEq(answer, answer1);
        assertEq(roundId, roundId1);
        assertEq(startedAt, startedAt1);
        assertEq(updatedAt, updatedAt1);
        assertEq(answeredInRound, answeredInRound1);
    }

    function testLatestRoundDataAfterPriceUpdate() public {
        // Update feed1 to a higher price than feed2
        int256 newPrice = 15e17;
        feed1.updateAnswer(newPrice);

        // Now feed2 should have the lower price
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            ojoPTFeed.latestRoundData();

        // Get data from feed2 for comparison
        (uint80 roundId2, int256 answer2, uint256 startedAt2, uint256 updatedAt2, uint80 answeredInRound2) =
            feed2.latestRoundData();

        // Verify that OjoPTFeed returns feed2's data (the lower price now)
        assertEq(answer, answer2);
        assertEq(roundId, roundId2);
        assertEq(startedAt, startedAt2);
        assertEq(updatedAt, updatedAt2);
        assertEq(answeredInRound, answeredInRound2);
    }

    function testBothFeedsUpdated() public {
        // Update both feeds
        feed1.updateAnswer(9e17);
        feed2.updateAnswer(8e17);

        // Now feed2 should have the lower price
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            ojoPTFeed.latestRoundData();

        // Get data from feed2 for comparison
        (uint80 roundId2, int256 answer2, uint256 startedAt2, uint256 updatedAt2, uint80 answeredInRound2) =
            feed2.latestRoundData();

        // Verify that OjoPTFeed returns feed2's data (the lower price)
        assertEq(answer, answer2);
        assertEq(answer, 8e17);
        assertEq(roundId, roundId2);
        assertEq(startedAt, startedAt2);
        assertEq(updatedAt, updatedAt2);
        assertEq(answeredInRound, answeredInRound2);
    }

    function testEqualPrices() public {
        // Update both feeds to the same price
        int256 samePrice = 1e18;
        feed1.updateAnswer(samePrice);
        feed2.updateAnswer(samePrice);

        // Get the latest round data from OjoPTFeed
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            ojoPTFeed.latestRoundData();

        // When prices are equal, OjoPTFeed should return feed1's data
        (uint80 roundId1, int256 answer1, uint256 startedAt1, uint256 updatedAt1, uint80 answeredInRound1) =
            feed1.latestRoundData();

        // Verify that OjoPTFeed returns feed1's data when prices are equal
        assertEq(answer, answer1);
        assertEq(roundId, roundId1);
        assertEq(startedAt, startedAt1);
        assertEq(updatedAt, updatedAt1);
        assertEq(answeredInRound, answeredInRound1);
    }
}
