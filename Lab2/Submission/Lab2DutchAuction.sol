// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/ERC20.sol";    
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC721/ERC721.sol";    

// Prerequisites / How to test
// 1. Have an NFT contract deployed (address A), mint a token to one address X
// 2. Have an ERC20 token contract deployed (address B), mint some amount to another address Y
// 3. Deploy this auction contract (address C) by inputing the NFT contract and ERC20 token addresses
// 4. User Y to approve the auction contract (C) some amount of tokens for purchasing the NFT
// 5. User X to approve the auction contract (C) the NFT they want to sell
// 6. User X to register its NFT into the auction
// 7. User Y may trigger the buy function to get the ownership of the NFT and transfer the NFT price to the previous owner (Y)

contract DutchAuction {
    IERC721 public NFT;
    IERC20 public token;
    uint256 private maxAuctionPeriod; // period in seconds
    uint256 public depreciationRate = 10;
    mapping(uint256 => Item) public items;
    uint256 public itemCount;

    // == Internal structs

    struct Item {
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

    // == Errors

    error ItemExpired(uint256 tokenID);

    // == Public functions

    function registerAuction(
        uint256 tokenID,
        uint256 initialPrice
    ) external ownership(tokenID) {
        // register item
        items[tokenID] = Item({
            owner: msg.sender,
            tokenID: tokenID,
            initialPrice: initialPrice,
            registrationTimestamp: block.timestamp + 1 
            // either Solidity or Remix is unable to store pure block.timestamp value to state (out of gas error), thus the + 1
            // check gist: https://gist.github.com/jeffdarmawan/371079b87ec73e6772028b0758bd05ab
        });
    }

    function cancelAunction(uint256 tokenID) public ownership(tokenID) itemRegistered(tokenID) {
        _removeAuctionItem(tokenID);
    }

    function getPrice(
        uint256 tokenID
    ) public itemRegistered(tokenID) returns (uint256) {
        uint256 currentPrice = _getCurrentPrice(tokenID);
        return currentPrice;
    }

    function buy(uint256 tokenID, uint256 setPrice) public itemRegistered(tokenID) {
        Item memory item = items[tokenID];
        uint256 currentPrice = _getCurrentPrice(tokenID);

        // check current price coverage
        require(currentPrice <= setPrice, "Amount paid does not cover current price");

        // check allowance
        require(token.allowance(msg.sender, address(this)) >= setPrice, "Amount to be paid is not available");

        // transfer token
        token.transferFrom(msg.sender, item.owner, currentPrice);

        // transfer NFT
        NFT.safeTransferFrom(item.owner, msg.sender, tokenID);

        // remove item from auction
        _removeAuctionItem(tokenID);
    }

    // == Internal functions

    function _removeAuctionItem(uint256 tokenID) private {
        delete items[tokenID];
    }

    function _getCurrentPrice(uint256 tokenID) private view returns(uint256) {
        Item memory item = items[tokenID];
        
        // price decreases by 10% each day
        uint256 daysPassed = uint256((block.timestamp - item.registrationTimestamp) / 86400);
        uint256 currentPrice = (item.initialPrice * (90 ** daysPassed))/(100 ** daysPassed);
        return currentPrice;
    }
}
