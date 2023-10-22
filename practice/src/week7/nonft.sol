// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


contract Nonsense is ERC721 {
  uint256 constant public tokenId = 0;
  constructor() ERC721("", "") {}
  function mint(address to) external returns (uint256) {
    require(to!=address(0), "zero address not allowed");
    _mint(to, tokenId);
    return tokenId;
  }
}

contract HW_Token is ERC721 {
  uint256 public counter = 0;
  constructor() ERC721("Don't send NFT to me", "NONFT") {}

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    address owner = ownerOf(tokenId);
    require(owner!=address(0), "NFT not exists");
    return "https://yellow-similar-roadrunner-408.mypinata.cloud/ipfs/QmVmKb6j5dcdFRM5cxtsgukSka48uKCdZRy9vSHrtm2XQG?_gl=1*ea76s5*_ga*MTMzNTkyNjAzMS4xNjk3NzE2NTY2*_ga_5RMPXG14TE*MTY5Nzk4NTgwMi4yLjEuMTY5Nzk4NTg0Ny4xNS4wLjA.";
  }
  
  function mint(address to) external returns (uint256) {
    require(to!=address(0), "zero address not allowed");
    uint256 originalTokenId = counter;
    _mint(to, counter);
    counter = counter + 1;
    return originalTokenId;
  }
}


contract NFTReceiver is IERC721Receiver {

    address tokenAddr;

    event ERC721ReceiveEvent(address indexed operator, address indexed from, uint256 indexed tokenId, bytes data);

    constructor(address _addr) {
        tokenAddr = _addr;
    }
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) public virtual override returns(bytes4) {
        
        emit ERC721ReceiveEvent(operator, from, tokenId, data);

        if(address(msg.sender)!=tokenAddr) {
            IERC721(msg.sender).safeTransferFrom(address(this), from, tokenId);
            HW_Token(tokenAddr).mint(from);
        }
        return this.onERC721Received.selector;
    }
}