// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ConfirmedOwner} from "@chainlink/contracts/ConfirmedOwner.sol";
import {CollateralAuctions} from "./CollateralAuctions.sol";

contract liquidator is ConfirmedOwner, ReentrancyGuard {
    address private engineAddress;
    collateralActions private i_cactions;

    constructor(address Owner) ConfirmedOwner(Owner) {
        Owner = engineAddress;
    }

    // 150$ worth of eth --> 75$ of our coin
    function checkHealthFactoury(address user) public {
        (uint256 decAmount, uint256 collateralAmount) = i_cactions._getUserInformation(_user);
    }

    // function _getAccountInformation(address _user) public view returns (uint256 decAmount, uint256 collateralValue) {
    //     (uint256 decAmount, uint256 collateralValue) = i_cactions._getUserInformation(_user);
    // }

    function _getUserCollateral(address _user) public view returns (uint256 userCollateral) {}
    function addsBonus() public {}
    function burn() public {}
    function calculatedAmountCollateral() public {}

    /**
     * Check User's Health:
     *
     *     The function first checks the financial health 
     *     of the user (how well they can repay their debt). 
     *     If the user's health is okay (above a certain threshold),
     *     the function stops and doesn't do anything further.
     *     Calculate Collateral Needed:
     *
     *     If the user's health is not okay, 
     *     the function calculates how much 
     *     of the user's asset (collateral) is needed 
     *     to cover the amount of debt you want to pay off.
     *     Add a Bonus:
     *
     *     The function adds a 10% bonus 
     *     to the amount of collateral needed. 
     *     This bonus is an extra reward for the person 
     *     (you) who is helping to fix the user's debt problem.
     *     Burn Tokens:
     *
     *     The function burns (destroys) the amount 
     *     of tokens you specified to cover the user's debt.
     *     This helps reduce the user's debt.
     *     Transfer Collateral:
     *
     *     The function takes the calculated amount of the user's collateral,
     *     including the bonus, and gives it to you.
     *     Check Improvement:
     *
     *     After all these actions, the function checks again to ensure
     *     the user's financial health has improved. If not, it stops with an error.
     */
    function liquidate() external {}
}
