// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import {AggregatorV3Interface} from "./interfaces/AggregatorV2V3Interface.sol";
import {AggregatorV2V3Interface} from "./interfaces/AggregatorV2V3Interface.sol";

contract OjoPTFeed is AggregatorV3Interface {
    uint256 constant DEFAULT_VERSION = 1;

    AggregatorV2V3Interface public FEED_1;
    AggregatorV2V3Interface public FEED_2;
    string private feedDescription;

    error GetRoundDataCanBeOnlyCalledWithLatestRound(uint80 requestedRoundId);

    function initialize(address _FEED_1, address _FEED_2) external {
        require(_FEED_1 != address(0), "Zero address for FEED_1");
        require(_FEED_2 != address(0), "Zero address for FEED_2");
        FEED_1 = AggregatorV2V3Interface(_FEED_1);
        FEED_2 = AggregatorV2V3Interface(_FEED_2);
        require(FEED_1.decimals() == FEED_2.decimals(), "FEED_1 decimals not equal to FEED_2 decimals");
        feedDescription = string(abi.encodePacked("Ojo PT Feed", FEED_1.description()));
    }

    function decimals() external view override returns (uint8) {
        return FEED_1.decimals();
    }

    function description() external view override returns (string memory) {
        return feedDescription;
    }

    function version() external view override returns (uint256) {
        return DEFAULT_VERSION;
    }

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            latestRoundData();
        if (_roundId != roundId) {
            revert GetRoundDataCanBeOnlyCalledWithLatestRound(_roundId);
        }
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }

    function latestRoundData()
        public
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        (uint80 roundId1, int256 answer1, uint256 startedAt1, uint256 updatedAt1, uint80 answeredInRound1) =
            FEED_1.latestRoundData();

        (uint80 roundId2, int256 answer2, uint256 startedAt2, uint256 updatedAt2, uint80 answeredInRound2) =
            FEED_2.latestRoundData();

        if (answer1 <= answer2) {
            return (roundId1, answer1, startedAt1, updatedAt1, answeredInRound1);
        } else {
            return (roundId2, answer2, startedAt2, updatedAt2, answeredInRound2);
        }
    }
}
