// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ConfirmedOwner} from "@chainlink/contracts/ConfirmedOwner.sol";

contract collateralActions is ConfirmedOwner, ReentrancyGuard {
    error CA__AmountShouldBeMoreThanZero();
    error CA__TokenAddressesAndPriceFeedsAddressesShouldBeSameLength();
    error CA__NotAlowedTokenToDeposit();
    error CA__FaildCollateralTransfer();

    address private engineAddress;
    address[] private tokenAddresses;
    address[] private priceFeedsAddresses;

    // token address and its priceFeed
    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amountToken)) internal s_collateralDeposited;
    mapping(address user => uint256 decAmount) internal s_decMinted;

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert CA__AmountShouldBeMoreThanZero();
        }
        _;
    }

    modifier isAlowedToken(address tokenAddress) {
        if (s_priceFeeds[tokenAddress] == address(0)) {
            revert CA__NotAlowedTokenToDeposit();
        }
        _;
    }

    constructor(address Owner, address[] memory _tokenAddresses, address[] memory _priceFeedsAddresses)
        ConfirmedOwner(Owner)
    {
        Owner = engineAddress;
        _tokenAddresses = tokenAddresses;
        _priceFeedsAddresses = priceFeedsAddresses;

        if (tokenAddresses.length != priceFeedsAddresses.length) {
            revert CA__TokenAddressesAndPriceFeedsAddressesShouldBeSameLength();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = s_priceFeeds[priceFeedsAddresses[i]];
        }
    }

    function depositCollateral(
        address caller, // The user address
        address tokenCollateralAddress, // @param token Collateral Address to chose wETH || wBTC
        uint256 amountCollateral // @param Amount collateral to deposit
    ) public moreThanZero(amountCollateral) isAlowedToken(tokenCollateralAddress) nonReentrant {
        // Add the user info into our mapping `s_collateralDeposited`
        s_collateralDeposited[caller][tokenCollateralAddress] += amountCollateral;
        // Then Transfer the collateral for the collateral token address to the engine address
        bool success = IERC20(tokenCollateralAddress).transferFrom(caller, engineAddress, amountCollateral);
        if (!success) revert CA__FaildCollateralTransfer();
    }

    function redeemCollateral(address from, address to, address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAlowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[from][tokenCollateralAddress] -= amountCollateral;
        bool success = IERC20(tokenCollateralAddress).transfer(to, amountCollateral);
        if (!success) revert CA__FaildCollateralTransfer();
    }

    function _getUserInformation(address _user) public view returns (uint256 decAmount, uint256 collateralAmount) {
        collateralAmount = s_collateralDeposited[_user][address(this)];
        decAmount = s_decMinted[_user];
    }
}
