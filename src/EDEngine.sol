// SPDX-License-Identifier: UNLICENSED

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

pragma solidity 0.8.23;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {EquiDime} from "./EquiDime.sol";

/*
 * @title EDEngine
 * @author Audit4me
 *
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg at all times.
 * This is a stablecoin with the properties:
 * - Exogenously Collateralized
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was backed by only WETH and WBTC.
 *
 * Our EDC system should always be "overcollateralized". At no point, should the value of
 * all collateral < the $ backed value of all the EDC.
 *
 * @notice This contract is the core of the Decentralized Stablecoin system. It handles all the logic
 * for minting and redeeming EDC, as well as depositing and withdrawing collateral.
 * @notice This contract is based on the MakerDAO DSS system
 */

contract EDEngine is ReentrancyGuard {
    EquiDime private immutable i_edc;
    // address private immutable i_tokenCollateralAddress;

    constructor() {}
    function depositCollateralAndMintEDC() external {}
    // Deposit wETH || wBTC

    function mintEDC(uint256 _amount) public {
        i_edc.mint(msg.sender, _amount);
    }

    function burnEDC(uint256 _amount) external {
        i_edc.burn(_amount);
    }

    // function _redeemCollateral() private {}
    // function _burnEDC() private {}
}
