// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Lab1 {
    uint256 price;
    uint256[] quantities;

    function setPrice(uint256 val) public {
        price = val;
    }

    function setQuantities(uint256[] calldata arr) public {
        quantities = arr;
    }

    function totalPrice() public view returns (uint256) {
        uint256 total = 0;
        for (uint i = 0; i < quantities.length; i ++) {
            uint256 toAdd = quantities[i] * price;
            total = total + toAdd;
        }

        return total;
    }
}