// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ConfirmedOwner} from "@chainlink/contracts/ConfirmedOwner.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/shared/interfaces/AggregatorV3Interface.sol";
import {CollateralActions } from "./CollateralActions.sol";
import {EDEngine } from "./EDEngine.sol";

contract Liquidator is ConfirmedOwner, ReentrancyGuard {
    AggregatorV3Interface internal priceFeed;
    CollateralActions private immutable i_coll;
    EDEngine private immutable i_engine;
    address private immutable _caller;

    error HealthFactorSufficient();
    error HealthFactorNotImprove();
    error DebtToCoverMustBeMoreThanZero();
    error NotEnoughDebtToCover();
    error BreaksHealthFactor();
    error HealthFactorOk();

    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; // 200% over-collateralized
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant FEED_PRECISION = 1e8;
    uint256 private constant LIQUIDATION_BONUS = 10; // 10% bonus
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18; // Minimum health factor (1.0)

    constructor(address owner) ConfirmedOwner(owner) {}

    /**
     * @notice Returns the USD value of the given collateral amount.
     * @param collateralToken The address of the collateral token.
     * @param amount The amount of collateral.
     * @return The USD value of the collateral.
     */
    function _getUsdValue(address collateralToken, uint256 amount) public view returns (uint256) {
        priceFeed = AggregatorV3Interface(collateralToken);
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }

    /**
     * @notice Returns the total DSC minted and collateral value in USD for a user.
     * @param user The address of the user.
     * @return totalDscMinted The total DSC minted by the user.
     * @return collateralValueInUsd The total collateral value in USD.
     */
    function getAccountInformation(address user)
        external
        view
        returns (uint256 totalDscMinted, uint256 collateralValueInUsd)
    {
        return i_coll._getUserInformation(user);
    }

    /**
     * @notice Calculates the health factor for a given DSC and collateral value.
     * @param totalDscMinted The total DSC minted.
     * @param collateralValueInUsd The collateral value in USD.
     * @return The calculated health factor.
     */
    function _calculateHealthFactor(
        uint256 totalDscMinted,
        uint256 collateralValueInUsd
    )
        internal
        pure
        returns (uint256)
    {
        if (totalDscMinted == 0) return type(uint256).max;
        uint256 collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralAdjustedForThreshold * PRECISION) / totalDscMinted;
    }

    /**
     * @notice Returns the health factor of a user.
     * @param user The address of the user.
     * @return The health factor of the user.
     */
    function _healthFactor(address user) private view returns (uint256) {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = i_coll._getUserInformation(user);
        return _calculateHealthFactor(totalDscMinted, collateralValueInUsd);
    }

    /**
     * @notice Reverts if the user's health factor is below the minimum threshold.
     * @param user The address of the user.
     */
    function revertIfHealthFactorIsBroken(address user) internal view {
        uint256 userHealthFactor = _healthFactor(user);
        if (userHealthFactor <= MIN_HEALTH_FACTOR) revert BreaksHealthFactor();
    }

    /**
     * @notice Liquidates a user's collateral position.
     * @param collateral The address of the collateral token.
     * @param user The address of the user.
     * @param debtToCover The amount of debt to cover.
     */
    function liquidate(address collateral, address user, uint256 debtToCover) external nonReentrant {
        uint256 startingUserHealthFactor = _healthFactor(user);
        if (startingUserHealthFactor >= MIN_HEALTH_FACTOR) revert HealthFactorOk();

        (uint256 decAmount, ) = i_coll._getUserInformation(user);
        uint256 collateralValueInUsd = _getUsdValue(collateral, debtToCover);
        uint256 bonusCollateral = (collateralValueInUsd * LIQUIDATION_BONUS) / LIQUIDATION_PRECISION;
        uint256 collateralAndBonus = collateralValueInUsd + bonusCollateral;

        i_coll.redeemCollateral(user, msg.sender, collateral, collateralAndBonus);
        i_coll._burnDsc(debtToCover, user, msg.sender);
    }
}
