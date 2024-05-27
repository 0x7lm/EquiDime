// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { Script }         from "forge-std/Script.sol";
import { MockAggregator } from "@chainlink/contracts/mocks/MockAggregator.sol";
import { ERC20Mock }      from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    MockAggregator public AggMock;

    struct NetworkConfig {
        address wethUsdPriceFeed;
        address wbtcUsdPriceFeed;
        address weth;
        address wbtc;
        uint256 deployerKey;
    }

    uint256 public constant DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory anvilNetworkConfig) {
        if (activeNetworkConfig.wethUsdPriceFeed != address(0)) {
            return activeNetworkConfig;
        }

        //AggMock = MockAggregator(0x123);

        AggMock.setLatestAnswer(2000e8);
        MockAggregator ethUsdPriceFeed = AggMock.latestAnswer();
        ERC20Mock wethMock = new ERC20Mock();

        AggMock.setLatestAnswer(1000e8);
        uint256 ansowr = AggMock.latestAnswer();
        MockAggregator btcUsdPriceFeed = ansowr;
        ERC20Mock wbtcMock = new ERC20Mock();

        anvilNetworkConfig = NetworkConfig({
            wethUsdPriceFeed: ethUsdPriceFeed,
            weth: address(wethMock),
            wbtcUsdPriceFeed: btcUsdPriceFeed,
            wbtc: address(wbtcMock),
            deployerKey: DEFAULT_ANVIL_PRIVATE_KEY
        });

        activeNetworkConfig = anvilNetworkConfig;
    }
}
