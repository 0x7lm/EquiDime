// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title EDEngine Contract
 * @author Audit4me
 * @notice This contract totly controll the EquiDime stableCoin
 */

contract EDEngine is ReentrancyGuard {
    function depositCollateralAndMintEDC() external {}
    function redeemCollateral() external {}
    function burnEDC() external {}
    function liquidate() external {}
    function mintEDC() public {}
    function depositCollateral() public {}
    function _redeemCollateral() private {}
    function _burnEDC() private {}
}