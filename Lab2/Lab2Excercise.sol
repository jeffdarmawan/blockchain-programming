// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/ERC20.sol";    
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC721/ERC721.sol";    

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// import "./../IERC20.sol";
// import "./../IERC721.sol";

contract DutchAuction {
    IERC721 private NFT;
    IERC20 private token;
    uint256 private maxAuctionPeriod; // period in seconds
    uint256 public depreciationRate = 10;
    mapping(uint256 => item) private items;

    // == Internal structs

    struct item {
        address owner;
        uint256 tokenID;
        uint256 initialPrice;
        uint256 registrationTimestamp;
    }

    // == Constructor
    
    constructor(
        address _NFT,
        address _token,
        uint256 _maxAuctionPeriod
    ) {
        NFT = IERC721(_NFT);
        token = IERC20(_token);
        maxAuctionPeriod = _maxAuctionPeriod;
    }

    // == Modifiers

    // ownership modifier
    modifier ownership(uint256 tokenID) {
        // check ownership
        require(NFT.ownerOf(tokenID) == msg.sender, "Not owner of the NFT");
        _;
    }

    // auction item checking
    modifier itemRegistered(uint256 tokenID) {
        // check if item is registered 
        require(items[tokenID].registrationTimestamp > 0, "Item not registered");

        // drop item if expired
        if (items[tokenID].registrationTimestamp + maxAuctionPeriod < block.timestamp) {
            _removeAuctionItem(tokenID);
            revert ItemExpired(tokenID);
        }
        _;
    }

    // == Public functions

    function registerAuction(
        uint256 calldata tokenID,
        uint256 calldata initialPrice
    ) public ownership(tokenID) {
        // check allowance
        NFT.getApproved(tokenId);

        // register item
        items[tokenID] = item({
            owner: msg.sender,
            tokenID: tokenID,
            price: initialPrice,
            registrationTimeStamp: block.timestamp
        });
    }

    function cancelAunction(uint256 tokenID) public ownership(tokenID) itemRegistered(tokenID) {
        _removeAuctionItem(tokenID);
    }

    function getPrice(
        uint256 tokenID
    ) public view itemRegistered(tokenID) returns (uint256) {
        currentPrice = _getCurrentPrice(tokenID);
        return currentPrice;
    }

    function buy(uint256 tokenID, uint256 setPrice) public itemRegistered(tokenID) {
        item = items[tokenID];
        currentPrice = _getCurrentPrice(tokenID);

        // check current price coverage
        require(currentPrice < setPrice, "Amount paid does not cover current price");

        // check allowance
        require(token.allowance(msg.sender, address(this)) >= setPrice, "Amount paid is not available");

        // transfer token
        token.transferFrom(msg.sender, item.owner, currentPrice);

        // transfer NFT
        NFT.safeTransferFrom(item.owner, msg.sender, tokenID);

        // remove item from auction
        _removeAuctionItem(tokenID);
    }

    // Internal functions

    function _removeAuctionItem(uint256 tokenID) private {
        delete items[tokenID];
    }

    function _getCurrentPrice(uint256 tokenID) private returns(uint256) {
        item = items[tokenID];
        daysPassed = uint256(item.registrationTimestamp / 86400);

        currentPrice = (item.initialPrice * (100 - (depreciationRate * daysPassed)).max(10))/100;
        return currentPrice;
    }
}
