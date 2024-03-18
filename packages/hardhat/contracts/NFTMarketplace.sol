// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721Holder, Ownable {
    uint256 public feePercentage;   // Fee percentage to be set by the marketplace owner
    uint256 private constant PERCENTAGE_BASE = 100;
    uint256 public minListingPrice;  // Minimum price allowed for listing an NFT
    uint256 public maxListingPrice;  // Maximum price allowed for listing an NFT
    uint256 public minTimeBetweenListings;  // Minimum time required between two consecutive listings
    uint256 public averageListingPrice;  // Average listing price
    address public paymentToken;  // Token address to be used for payments
    address public manager;  // Manager address for additional administrative functions

    struct Listing {
        address seller;
        uint256 price;
        bool isActive;
        uint256 timeLastListed;
    }

    mapping(address => mapping(uint256 => Listing)) private listings;

    event NFTListed(address indexed seller, uint256 indexed tokenId, uint256 price);
    event NFTSold(address indexed seller, address indexed buyer, uint256 indexed tokenId, uint256 price);
    event NFTPriceChanged(address indexed seller, uint256 indexed tokenId, uint256 newPrice);
    event NFTUnlisted(address indexed seller, uint256 indexed tokenId);

    // Constructor with additional 'feePercentage' argument
    constructor(uint256 _feePercentage) {
        feePercentage = _feePercentage;
        // Other parameters can be set after deploying the contract
    }

    // Function to list an NFT for sale
    function listNFT(address nftContract, uint256 tokenId, uint256 price) external {
        require(price >= minListingPrice, "Price must be greater than or equal to the minimum listing price");
        require(price <= maxListingPrice, "Price must be less than or equal to the maximum listing price");
        require(block.timestamp - listings[nftContract][tokenId].timeLastListed >= minTimeBetweenListings, "Cannot list the NFT again so soon");

        // Transfer the NFT from the seller to the marketplace contract
        IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId);

        // Create a new listing
        listings[nftContract][tokenId] = Listing({
            seller: msg.sender,
            price: price,
            isActive: true,
            timeLastListed: block.timestamp
        });

        emit NFTListed(msg.sender, tokenId, price);
    }

    // Rest of the contract code remains the same...

}