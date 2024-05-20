// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ConfirmedOwner} from "@chainlink/contracts/ConfirmedOwner.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/shared/interfaces/AggregatorV3Interface.sol";
import {collateralActions } from "./CollateralActions.sol";

contract liquidator is ConfirmedOwner, ReentrancyGuard {
    AggregatorV3Interface internal dataFeed;
    address private engineAddress;
    collateralActions private immutable i_collateralActions;

    error HealthFactorSufficient();
    error HealthFactorNotImprove();

    uint256 private constant PRECISION = 1e18;
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;
    //uint256 private constant FEED_PRECISION = 1e8;

    constructor(address Owner) ConfirmedOwner(Owner) {
        Owner = engineAddress;
    }

    // 150$ worth of eth --> 75$ of our coin
    function checkHealthFactor(address _user) public {
        (uint256 decAmount, uint256 collateralAmount) = i_collateralActions._getUserInformation(_user);
    }
    
    function calculateUsdValue() public {}
    function getUsdValue() public {}
    function burnTokens() public {}
    function transferCollateral() public {}


    /**
     * @notice Liquidates a user's collateral position.
     *
     * Steps:
     * 1. Checks the user's health factor. If it is above the threshold, the function stops.
     * 2. Calculates the required collateral to cover the specified debt amount.
     * 3. Adds a 10% bonus to the calculated collateral as a reward for liquidating.
     * 4. Burns the specified amount of tokens to reduce the user's debt.
     * 5. Transfers the calculated collateral amount, including the bonus, to the liquidator.
     * 6. Checks the user's health factor again to ensure it has improved. If not, it reverts.
     */
    function liquidate(address user, uint256 debtToCover, address collateralToken) external nonReentrant {
        (uint256 debtAmount, uint256 collateralAmount) = i_collateralActions._getUserInformation(user);
        uint256 userHealthFactor = checkHealthFactor(user);
        if (userHealthFactor > MIN_HEALTH_FACTOR) revert HealthFactorSufficient();

        uint256 collateralValueInUsd = calculateUsdValue(collateralAmount, getUsdValue(collateralToken, collateralAmount));
        uint256 collateralRequired = (debtToCover * PRECISION) / collateralValueInUsd;
        uint256 bonus = (collateralRequired * 10) / 100;

        burnTokens(debtToCover);
        transferCollateral(user, collateralToken, collateralRequired + bonus);

        uint256 newHealthFactor = checkHealthFactor(user);
        if (newHealthFactor < userHealthFactor) revert HealthFactorNotImprove();
    }

}
