// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { Script }          from "forge-std/Script.sol";
import {EquiDime }         from "../src/EquiDime.sol";
import {CollateralActions} from "../src/CollateralActions.sol";
import {Liquidator }       from "../src/Liquidator.sol";
import {HelperConfig }     from "./HelperConfig.s.sol";

contract Deployer is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns (EquiDime, CollateralActions, Liquidator, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig(); // This comes with our mocks!

        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployerKey) =
            helperConfig.activeNetworkConfig();
        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed];

        vm.startBroadcast(deployerKey);
        EquiDime dsc = new EquiDime();
        CollateralActions coll = new CollateralActions(tokenAddresses, priceFeedAddresses, address(dsc));
        dsc.transferOwnership(address(coll));
        vm.stopBroadcast();
        return (dsc, coll, helperConfig);
    }
}