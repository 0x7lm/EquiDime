// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { Script }          from "forge-std/Script.sol";
import {console }          from "forge-std/console.sol";
import {EquiDime }         from "../src/EquiDime.sol";
import {CollateralActions} from "../src/CollateralActions.sol";
import {Liquidator }       from "../src/Liquidator.sol";
import {HelperConfig }     from "./HelperConfig.s.sol";

contract Deployer is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns (CollateralActions , Liquidator, EquiDime, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig(); // This comes with our mocks!

        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployerKey) =
            helperConfig.activeNetworkConfig();
        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed];

        vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
        CollateralActions coll = new CollateralActions(tokenAddresses, priceFeedAddresses);
        address Owner = address(coll);
        
        EquiDime dsc = new EquiDime(Owner);
       
        Liquidator liq = new Liquidator(Owner);
        console.log(wbtcUsdPriceFeed);
        
        vm.stopBroadcast();
        return (coll, liq, dsc , helperConfig);
    }
}