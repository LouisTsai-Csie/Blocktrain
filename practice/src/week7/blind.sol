// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Dutch Auction NFT Contract
 * @author LouisTsai-Csie @GitHub
 * @notice practice for AppWorks School Blockchain Program batch 3
 */

contract BlindNFT is ERC721, Ownable {

    // CONSTANT VARIABLES

    uint256 public constant TOTAL_SUPPLY = 500;
    uint256 public constant START_AUCTION_PRICE = 1 ether;
    uint256 public constant END_AUCTION_PRICE = 0.1 ether;
    uint256 public constant AUCTION_DURATION = 10 minutes;
    uint256 public constant AUCTION_DROP_INTERVAL = 1 minutes;
    uint256 public constant AUCTION_DROP_PER_INTERVAL = (START_AUCTION_PRICE - END_AUCTION_PRICE) / (AUCTION_DURATION / AUCTION_DROP_INTERVAL);
    uint256 public constant REVEAL_BLIND_DURATION = 1 days;
    
    // STATE VARIABLES

    enum tokenCategory {A, B, C, D, E}
    uint256 public auctionStartTime;
    uint256 public tokenId;
    mapping(address=>uint256) tokenMapping;
    mapping(address=>bool) revealBlind;
    mapping(uint256=>tokenCategory) categories;
    
    // CONSTRUCTOR
    constructor() ERC721("Blind NFT", "BLIND") Ownable(msg.sender){
        auctionStartTime = 0;
        tokenId = 1;
    }

    // FUNCTIONS

    /// @notice The contract owner can configure the starting time for auction
    /// @dev Only the contract creator has the priviledge to set auction time
    function setAuctionStartTime(uint256 timestamp) external onlyOwner {
        require(timestamp >= block.timestamp, "Only future timestamp allowed");
        auctionStartTime = timestamp;
    }

    /// @notice The auction price derecreases by the time with ratio AUCTION_DROP_PER_INTERVAL per interval
    /// @dev    Ratio calculation should be careful for the ordering of multiplication and division due to precision reason
    /// @return The current auction price
    function getAuctionPrice() public view returns(uint256) {
        uint256 timestamp = block.timestamp;

        if(timestamp < auctionStartTime) 
            return START_AUCTION_PRICE;
        else if(timestamp - auctionStartTime > AUCTION_DURATION) 
            return END_AUCTION_PRICE;
        
        return START_AUCTION_PRICE - ((timestamp - auctionStartTime) * AUCTION_DROP_PER_INTERVAL) / AUCTION_DROP_INTERVAL;
    }

    /// @notice Mint the NFT with the Dutch Auction price calculation rules
    /// @dev Make sure there is no reentrancy concerns by following CEI pattern
    /// @return The minted token ID
    function auctionMintNFT() external payable returns(uint256) {
        uint256 startTime = auctionStartTime;
        require(startTime!=0, "The auction start time not set");
        require(block.timestamp >= startTime, "The auction not started");

        require(tokenId<=TOTAL_SUPPLY, "Exceed total supply");

        require(balanceOf(msg.sender)!=0, "User already minted token before");
        require(tokenMapping[msg.sender]!=0, "User already minted token before");

        uint256 totalCost = getAuctionPrice();
        require(msg.value >= totalCost, "Insufficient ether for auction");

        uint256 originalTokenId = tokenId;
        tokenMapping[msg.sender] = originalTokenId;
        _safeMint(msg.sender, tokenId);
        tokenId += 1;


        if (msg.value > totalCost) {
            uint256 amount = msg.value - totalCost;
            (bool success, ) = payable(msg.sender).call{value: amount}("");
            require(success, "Fail to refund ether");
        }

        return originalTokenId;
    }


    /// @notice Reveal blind and check your NFT after the locking period
    /// @dev The randomness is not secure, Chainlink VRF should be implemented for safety reason
    function revealBlindNFT() public {
        require(block.timestamp < auctionStartTime + REVEAL_BLIND_DURATION, "Reveal blind not started");

        require(!revealBlind[msg.sender], "User already reveal blind");

        require(balanceOf(msg.sender)!=0, "User not mint token before");

        uint256 randomNumber = uint256(uint160(address(msg.sender)));

        revealBlind[msg.sender] = true;

        uint256 Id = tokenMapping[msg.sender];

        uint256 result = randomNumber%5;
        if(result == 0) categories[Id] = tokenCategory.A;
        else if(result == 1) categories[Id] = tokenCategory.B;
        else if(result == 2) categories[Id] = tokenCategory.C;
        else if(result == 3) categories[Id] = tokenCategory.D;
        else categories[Id] = tokenCategory.E;       
    }

    /// @notice Return the token URI of your NFT based on the result of revealing blind
    /// @dev If the token has not yet revealed, return empty string for token URI
    /// @return Token URI of ERC721 based on ERC721Metadata
    function tokenURI(uint256 Id) public view override returns (string memory) {
        require(Id<tokenId, "NFT not exists");
        bool revealed = revealBlind[msg.sender];

        if(!revealed) return "";

        tokenCategory category = categories[Id];

        if(category == tokenCategory.A) {
            return "A";
        } else if(category == tokenCategory.B) {
            return "B";
        } else if(category == tokenCategory.C) {
            return "C";
        } else if(category == tokenCategory.D) {
            return "D";
        }
        return "E";
    }
}