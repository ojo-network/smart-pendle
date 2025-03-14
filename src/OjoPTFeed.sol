// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import {AggregatorV3Interface} from "./interfaces/AggregatorV2V3Interface.sol";
import {AggregatorV2V3Interface} from "./interfaces/AggregatorV2V3Interface.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract OjoPTFeed is AggregatorV3Interface, Initializable {
    uint256 constant DEFAULT_VERSION = 1;
    uint256 public constant STALENESS_THRESHOLD = 24 hours;

    AggregatorV2V3Interface public FEED_1;
    AggregatorV2V3Interface public FEED_2;
    string private feedDescription;

    error GetRoundDataCanBeOnlyCalledWithLatestRound(uint80 requestedRoundId);
    error StaleOracleData(uint256 timestamp, uint256 threshold);

    function initialize(address _FEED_1, address _FEED_2) external initializer {
        require(_FEED_1 != address(0), "Zero address for FEED_1");
        require(_FEED_2 != address(0), "Zero address for FEED_2");

        AggregatorV2V3Interface feed1 = AggregatorV2V3Interface(_FEED_1);
        AggregatorV2V3Interface feed2 = AggregatorV2V3Interface(_FEED_2);

        require(feed1.decimals() == feed2.decimals(), "FEED_1 decimals not equal to FEED_2 decimals");

        FEED_1 = feed1;
        FEED_2 = feed2;
        feedDescription = string(abi.encodePacked("Ojo PT Feed ", feed1.description()));
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
        (roundId, answer, startedAt, updatedAt, answeredInRound) = latestRoundData();
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

        if (updatedAt1 != 0 && block.timestamp - updatedAt1 > STALENESS_THRESHOLD) {
            revert StaleOracleData(updatedAt1, STALENESS_THRESHOLD);
        }

        if (updatedAt2 != 0 && block.timestamp - updatedAt2 > STALENESS_THRESHOLD) {
            revert StaleOracleData(updatedAt2, STALENESS_THRESHOLD);
        }

        if (answer1 <= answer2) {
            return (roundId1, answer1, startedAt1, updatedAt1, answeredInRound1);
        } else {
            return (roundId2, answer2, startedAt2, updatedAt2, answeredInRound2);
        }
    }

    function getActiveOracle() external view returns (address) {
        (, int256 answer1,,,) = FEED_1.latestRoundData();
        (, int256 answer2,,,) = FEED_2.latestRoundData();

        if (answer1 <= answer2) {
            return address(FEED_1);
        } else {
            return address(FEED_2);
        }
    }
}
