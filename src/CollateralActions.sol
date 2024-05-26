// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ConfirmedOwner} from "@chainlink/contracts/ConfirmedOwner.sol";
import {EquiDime} from "./EquiDime.sol";
import {Liquidator} from "./Liquidator.sol";

contract CollateralActions is ConfirmedOwner, ReentrancyGuard {
    error CA__AmountShouldBeMoreThanZero();
    error CA__TokenAddressesAndPriceFeedsAddressesShouldBeSameLength();
    error CA__NotAllowedTokenToDeposit();
    error CA__MintFailed();
    error CA__FailedCollateralTransfer();

    EquiDime private i_main;
    Liquidator private i_liq;

    // address[] private tokenAddresses;
    // address[] private priceFeedsAddresses;

    // token address and its priceFeed
    mapping(address => address) private s_priceFeeds;
    mapping(address => mapping(address => uint256)) internal s_collateralDeposited;
    mapping(address => uint256) private s_decMinted;

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
        // tokenAddresses = _tokenAddresses;
        // priceFeedsAddresses = _priceFeedsAddresses;

        if (_tokenAddresses.length != _priceFeedsAddresses.length) {
            revert CA__TokenAddressesAndPriceFeedsAddressesShouldBeSameLength();
        }
        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            s_priceFeeds[_tokenAddresses[i]] = _priceFeedsAddresses[i];
        }
    }

    function depositCollateral(
        address caller, // The user address
        address tokenCollateralAddress, // @param token Collateral Address to choose wETH || wBTC
        uint256 amountCollateral // @param Amount collateral to deposit
    ) public moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant {
        // Add the user info into our mapping `s_collateralDeposited`
        s_collateralDeposited[caller][tokenCollateralAddress] += amountCollateral;
        // Then transfer the collateral from the caller to the collateral address
        bool success = IERC20(tokenCollateralAddress).transferFrom(caller, address(this), amountCollateral);
        if (!success) revert CA__FailedCollateralTransfer();
        mintDsc(amountCollateral, tokenCollateralAddress);
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
        i_main.transferFrom(decFrom, address(this), amountDecToBurn);
        i_main.burn(amountDecToBurn);
    }
    
    function mintDsc(uint256 amount, address collateralToken) internal {
        uint256 amountEDCToMint = i_liq._getUsdValue(collateralToken, amount);
        s_decMinted[msg.sender] += amountEDCToMint;
        i_liq.revertIfHealthFactorIsBroken(msg.sender);
        bool minted = i_main.mint(msg.sender, amountEDCToMint);
        if (minted != true) revert CA__MintFailed();
    }

    function _getUserInformation(address user) public view returns (uint256 dec, uint256 collateral) {
        collateral = s_collateralDeposited[user][address(this)];
        dec = s_decMinted[user];
    }

}