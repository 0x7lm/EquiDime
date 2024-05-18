// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ConfirmedOwner} from "@chainlink/contracts/ConfirmedOwner.sol";

contract liduidator is ConfirmedOwner, ReentrancyGuard {
    address private engineAddress;

    constructor(address Owner) ConfirmedOwner(Owner) {
        Owner = engineAddress;
    }

    function liquidate() external {}
}
