// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ConfirmedOwner} from "@chainlink/contracts/ConfirmedOwner.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/shared/interfaces/AggregatorV3Interface.sol";
import {collateralActions } from "./CollateralActions.sol";
import {EDEngine } from "./EDEngine.sol";

contract liquidator is ConfirmedOwner, ReentrancyGuard {
    AggregatorV3Interface internal priceFeed;
    collateralActions private immutable i_collateralActions;
    EDEngine private immutable engineAddress;
    address private immutable _caller;
    //address[] private _priceFeeds;

    error HealthFactorSufficient();
    error HealthFactorNotImprove();
    error debtToCoverMustBeMoreThanZero();
    error notEnoughDebtToCover();

    
    uint256 private constant PRECISION = 1e18;
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant LIQUIDATION_BONUS = 10; // 10% bonus
    uint256 private constant MIN_HEALTH_FACTOR = 1e18; // Placeholder for minimum health factor (1.0)

    constructor(address owner) ConfirmedOwner(owner) {}

    function getUsdValue(address collateralToken, uint256 amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(collateralToken);
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // 1e10 = 100_00_00_00_00 
        // 1e8  = 100_00_00_00
        // price = 7036_00_00_00_00 * 1e10 
        // 7036_00_00_00_00_00_00_00_00_00 * amount / 1e18 --> Amount Price 
        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }

    /**
     * @notice Liquidates a user's collateral position.
     *
     * Steps:
     * 1. Checks the user's health factor. If it is above the threshold, the function stops.
     * 2. Calculates the required collateral to cover the specified dec amount.
     * 3. Adds a 10% bonus to the calculated collateral as a reward for liquidating.
     * 4. Burns the specified amount of tokens to reduce the user's dec.
     * 5. Transfers the calculated collateral amount, including the bonus, to the liquidator.
     * 6. Checks the user's health factor again to ensure it has improved. If not, it reverts.
     */
    function liquidate(address user, uint256 debtToCover, address collateralToken, address tokenCollateralAddress, uint256 amount, uint256 userDebtAmount) external nonReentrant {
        (uint256 decAmount, ) = i_collateralActions._getUserInformation(user);
        if(debtToCover < 0) revert debtToCoverMustBeMoreThanZero();
        if(userDebtAmount <= debtToCover ) revert notEnoughDebtToCover();
        uint256 collateralValueInUsd = getUsdValue(collateralToken, amount);
        uint256 userHealthFactor = (collateralValueInUsd * PRECISION) / userDebtAmount;
        if (userHealthFactor > MIN_HEALTH_FACTOR ) revert HealthFactorSufficient();

        uint256 collateralToSeize = (debtToCover * PRECISION) / collateralValueInUsd;
        uint256 bonusCollateral = (collateralToSeize * LIQUIDATION_BONUS) / 100;
    }

}