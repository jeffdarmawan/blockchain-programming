// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./../IERC20.sol";

contract MyNFT is ERC721 {
    function mint(address to, uint256 id) external {
        _mint(to, id);
    }

    function burn(uint256 id) external {
        require(msg.sender == _ownerOf[id], "not owner");
        _burn(id);
    }
}