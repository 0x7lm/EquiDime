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
import {CollateralActions} from "./CollateralActions.sol";
import {Liquidator} from "./Liquidator.sol";

/*
 * @title EDEngine
 * @notice This contract is the core of the Decentralized Stablecoin system. It handles all the logic
 * for minting and redeeming EDC, as well as depositing and withdrawing collateral.
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
 * @dev This contract is based on the MakerDAO DSS system.
 */

contract EDEngine is ReentrancyGuard {
    // Immutable state variables
    EquiDime private immutable i_edc;
    CollateralActions private immutable i_colaction;
    Liquidator private immutable i_liq;

    /**
     * @notice Constructor initializes the EquiDime, CollateralActions, and Liquidator contracts.
     * @param tokenAddresses An array of token addresses allowed as collateral.
     * @param priceFeedAddresses An array of price feed addresses corresponding to the collateral tokens.
     */
    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses) {
        i_edc = EquiDime(address(this));
        i_colaction = new CollateralActions(address(this), tokenAddresses, priceFeedAddresses);
        i_liq = new Liquidator(address(this));
    }


    /**
     * @notice Mints EDC tokens to the sender.
     * @param _amount The amount of EDC tokens to mint.
     */
    function mintEDC(uint256 _amount) public {
        i_edc.mint(msg.sender, _amount);
    }

    /**
     * @notice Burns EDC tokens from the sender.
     * @param _amount The amount of EDC tokens to burn.
     */
    function burnEDC(uint256 _amount) external {
        i_edc.burn(_amount);
    }

    /**
     * @notice Transfers EDC tokens from one address to another.
     * @param from The address to transfer from.
     * @param value The amount of EDC tokens to transfer.
     */
    function _transferFrom(address from, uint256 value) external {
        i_edc.transferFrom(from, address(this), value);
    }
}
