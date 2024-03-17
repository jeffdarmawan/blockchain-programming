// Instruction:
// Build a smart contract for a simple stock management system. The contract stores
// multiple items with additional information; name, price, quantity, and isSoldOut. The
// contract should implement the following functions.
// 1. addItem
// This function registers an item in the contract with user-given parameters; name,
// price, quantity. The item should set `isSoldout` value as `false` indicating the item
// has not been sold out. The added items are assigned index numbers starting from 0
// in sequential order.
// 2. soldOut
// This function has a user-given parameter indicating the index of a stored item. It
// sets the value of `isSoldOut` to `true` for the selected item by the index.
// 3. numItem
// This function returns the number of stored items.
// 4. totalSales
// This function returns the total value of sold-out items. It returns the sum of
// (price*quantity) only for sold-out items. The sold-out item can be distinguished by
// `isSoldOut` value of each item

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Lab1Exercise {
    struct Item {
        string name;
        uint256 price;
        uint256 quantity;
        bool isSoldOut;
    }

    Item[] items;

    function addItem(string calldata name, uint256 price, uint256 quantity) public {
        Item memory newItem = Item(name, price, quantity, false);
        items.push(newItem);
    }

    function soldOut(uint256 index) public {
        Item storage item = items[index];
        item.isSoldOut = true;
    }

    function numItem() public view returns (uint256) {
        return items.length;
    }

    function totalSales() public view returns (uint256) {
        uint256 total = 0;
        for (uint i = 0; i < items.length; i++) {
            if (items[i].isSoldOut) {
                total = total + (items[i].price * items[i].quantity);
            }
        }

        return total;
    }
}