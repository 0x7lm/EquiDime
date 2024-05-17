// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { ERC20Burnable, ERC20 } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { ConfirmedOwner } from "@chainlink/contracts/ConfirmedOwner.sol";
/**
 * @title EquiDime StableCoin Contract
 * @author Audit4me
 * @notice ERC20 StableCoin Contract Controlled By EDEngine Contract
 */

contract EquiDime is ERC20Burnable, ConfirmedOwner {
    
    //Custem Errors
    error EquiDime__ZeroAddressPassed();
    error EquiDime__AmountShoudBeMoreThanZero();
    error EquiDime__AmountShoudBeMoreThanUrBalance();
    
    address private controller;

    //Functions
    constructor(address _controllerAddress) ERC20("EquiDime", "EQD") ConfirmedOwner(controller) {
        controller = _controllerAddress;
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns(bool) {
      if (_to == address(0)) {
        revert EquiDime__ZeroAddressPassed();
      }
      if (_amount <= 0 ) {
        revert EquiDime__AmountShoudBeMoreThanZero();
      }

      _mint(_to, _amount);
      return true;
    }

    function burn(uint256 _amount) public onlyOwner override {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0 ) {
            revert EquiDime__AmountShoudBeMoreThanZero();
        }
        if (balance < _amount ) {
            revert EquiDime__AmountShoudBeMoreThanUrBalance();
        }
        super.burn(_amount);
    }
}