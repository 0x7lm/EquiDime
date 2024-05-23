// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ConfirmedOwner} from "@chainlink/contracts/ConfirmedOwner.sol";
import { EDEngine} from "./EDEngine.sol";

contract CollateralActions is ConfirmedOwner, ReentrancyGuard {
    error CA__AmountShouldBeMoreThanZero();
    error CA__TokenAddressesAndPriceFeedsAddressesShouldBeSameLength();
    error CA__NotAllowedTokenToDeposit();
    error CA__FailedCollateralTransfer();

    EDEngine private i_engine;
    address[] private tokenAddresses;
    address[] private priceFeedsAddresses;

    // token address and its priceFeed
    mapping(address => address) private s_priceFeeds;
    mapping(address => mapping(address => uint256)) internal s_collateralDeposited;
    mapping(address => uint256) internal s_decMinted;

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert CA__AmountShouldBeMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address tokenAddress) {
        if (s_priceFeeds[tokenAddress] == address(0)) {
            revert CA__NotAllowedTokenToDeposit();
        }
        _;
    }

    constructor(address owner, address[] memory _tokenAddresses, address[] memory _priceFeedsAddresses)
        ConfirmedOwner(owner)
    {
        tokenAddresses = _tokenAddresses;
        priceFeedsAddresses = _priceFeedsAddresses;

        if (tokenAddresses.length != priceFeedsAddresses.length) {
            revert CA__TokenAddressesAndPriceFeedsAddressesShouldBeSameLength();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedsAddresses[i];
        }
    }

    function depositCollateral(
        address caller, // The user address
        address tokenCollateralAddress, // @param token Collateral Address to choose wETH || wBTC
        uint256 amountCollateral // @param Amount collateral to deposit
    ) public moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant {
        // Add the user info into our mapping `s_collateralDeposited`
        s_collateralDeposited[caller][tokenCollateralAddress] += amountCollateral;
        // Then transfer the collateral from the caller to the engine address
        bool success = IERC20(tokenCollateralAddress).transferFrom(caller, address(i_engine), amountCollateral);
        if (!success) revert CA__FailedCollateralTransfer();
    }

    function redeemCollateral(
        address from, 
        address to, 
        address tokenCollateralAddress, 
        uint256 amountCollateral
    ) external moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant {
        s_collateralDeposited[from][tokenCollateralAddress] -= amountCollateral;
        bool success = IERC20(tokenCollateralAddress).transfer(to, amountCollateral);
        if (!success) revert CA__FailedCollateralTransfer();
    }

    function _burnDsc(uint256 amountDecToBurn, address onBehalfOf, address decFrom) external {
        s_decMinted[onBehalfOf] -= amountDecToBurn;
        i_engine._transferFrom(decFrom, amountDecToBurn);
        i_engine.burnEDC(amountDecToBurn);
    }

    function _getUserInformation(address user) public view returns (uint256 decAmount, uint256 collateralAmount) {
        collateralAmount = s_collateralDeposited[user][address(this)];
        decAmount = s_decMinted[user];
    }

    function _getUserCollateralToken(address token) public view returns (address) {
        return s_priceFeeds[token];
    }
}