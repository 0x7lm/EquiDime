# EquiDime Protocol

The EquiDime Protocol is a decentralized stablecoin system designed to be minimal and maintain a 1 token = $1 peg. The system is overcollateralized, ensuring that the value of all collateral is always greater than the value of all issued stablecoins (EDC).
`Just MVP Protocol based on DAI token Protocol`

## Overview

The protocol consists of four main contracts:

1. `EquiDime.sol` - The ERC20 token contract for EquiDime (EDC).
2. `CollateralActions.sol` - Manages collateral deposits and redemptions.
3. `Liquidator.sol` - Handles liquidation of undercollateralized positions.

## Contracts

### EquiDime.sol

The `EquiDime` contract defines the stablecoin (EDC). It includes functions to mint and burn tokens, which can only be called by the collateralActions contract.

### CollateralActions.sol

The `CollateralActions` contract handles the depositing and redeeming of collateral. It ensures that only the collateralActions contract can call its functions, maintaining security and proper flow of operations.

### Liquidator.sol

The `Liquidator` contract manages the liquidation process. It interacts with the `CollateralActions` contract to redeem collateral and with the `EquiDime` contract to burn the necessary amount of tokens.

## Usage

### Deposit Collateral and Mint EDC

Users can deposit collateral and mint EDC by calling the `depositCollateralAndMintEDC` function:

```solidity
collateralActions.depositCollateralAndMintEDC(tokenCollateralAddress, amountCollateral);
```

### Mint EDC

Users can mint additional EDC (if eligible) by calling the `mintEDC` function:

```solidity
collateralActions.mintEDC(amount);
```

### Burn EDC

Users can burn EDC by calling the `burnEDC` function:

```solidity
collateralActions.burnEDC(amount);
```

### Liquidate Under-collateralized Position

Liquidators can liquidate an under-collateralized position by calling the `liquidate` function:

```solidity
collateralActions.liquidate(user, token, debtToCover);
```

## Security

- Only the collateralActions contract can call sensitive functions in `CollateralActions` and `EquiDime`.
- Reentrancy guards are in place to prevent reentrancy attacks.
- Proper checks are implemented to ensure that health factors and collateralization are maintained.

## Contributing

You welcome dude! Fork the repository (Learn , play with it, miss things) and submit pull requests for any improvements or `bug fixes`.

## License

This project is licensed under the MIT License.

---

This README provides a concise overview of the EquiDime Protocol, its components, usage.

Im using [Foundry](https://book.getfoundry.sh/) .cheak the book.