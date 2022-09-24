//SPDX-License-Identifier: MIT
// Art by @walshe_steve // Copyright © Steve Walshe
// Code by @0xGeeLoko


pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./DropERC721.sol";



contract Gen is ERC721, ERC721Enumerable, Ownable {
    using Math for uint256;
    using Strings for string;
    using Strings for uint256;

    uint256 public constant MAX_GENS = 6000;
    uint256 public maxPerMint = 100;
    bool public mintingIsActive = false;
    

    // current seasonal collection baseURI and is used for any new bioupgrading / minting
    // BioUpgrading (allowed only to a current seasonal collection)
    // Minting (only once): Arcturium => Gen current collection
    string public currentSeasonalCollectionURI;

    uint256 public mintPrice = 0.0 ether;

    // mapping between original Arcturium tokenId => Gen tokenId, to allow minting of unminted
    mapping(uint256 => bool) private _gensMinted;
    // Mapping between tokenId => seasonal collectiong baseURI
    mapping(uint256 => string) private _gensRegistry;

    address public arcturiumContract = 0x4B396F08cDa12A9F6C0cD9cBab6bDfa06585077B;

    event GenMinted(uint256 tokenId);
    event GenUpdated(uint256 tokenId, string newBaseURI);

    constructor(string memory baseURI) ERC721("Gen", "Gen") {
        currentSeasonalCollectionURI = baseURI;
    }
    /*
    * Withdraw funds
    */
    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "Insufficient balance");

        uint256 balance = address(this).balance;
        Address.sendValue(payable(msg.sender), balance);
    }

    /*
    * The ground cost of public mint & BioUpgrades
    */
    function setMintPrice(uint256 newPrice) public onlyOwner {
        mintPrice = newPrice;
    }

    function setMintMax(uint256 newMax) public onlyOwner {
        maxPerMint = newMax;
    }
    //---------------------------------------------------------------------------------
    /**
    * Current on-going collection that is avaiable to BioUpgrade or use as base for minting
    */
    function setCurrentCollectionBaseURI(string memory newuri) public onlyOwner {
        currentSeasonalCollectionURI = newuri;
    }

    
    /*
    * Pause minting if active, make active if paused
    */
    function flipMintingState() public onlyOwner {
        mintingIsActive = !mintingIsActive;
    }
    
    

    
    /**
    * Mints Gen (only allowed if you holding Arcturium and corresponding Gen has not been minted)
    */
    function mintGen(uint256[] memory tokenIds) public {
        require(tokenIds.length <= maxPerMint, "Minting too much at once is not supported");
        require(mintingIsActive, "Minting must be active to mint Gen");
        require((totalSupply() + tokenIds.length) <= MAX_GENS, "Mint would exceed max supply of Gen0");
        DropERC721 arcturium = DropERC721(arcturiumContract);
        for(uint i = 0; i < tokenIds.length; i++) {
            // Allow minting if we are the owner of original Arcturium, skip otherwise
            if (arcturium.ownerOf(tokenIds[i]) != msg.sender) {
                require(false, "Attempt to mint Gen for non owned Arcturium");
            }
            // Reject Mint if token exist
            if (_exists(tokenIds[i])) {
                require(false, "Trying to mint existing Gen");
            }
        }
        
        for(uint i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] < MAX_GENS, "TokenID would exceed max supply of Gen0");
            createGen(msg.sender, tokenIds[i]);
        }
    }

    
    /// Internal
    function createGen(address mintAddress, uint256 tokenId) private {
      if (tokenId < MAX_GENS && !_exists(tokenId) && _gensMinted[tokenId] == false) {
          _safeMint(mintAddress, tokenId);
          _gensMinted[tokenId] = true;
          _gensRegistry[tokenId] = currentSeasonalCollectionURI;
          // fire event in logs
          emit GenMinted(tokenId);
      }
    }

    /// ERC721 related
    /**
     * @dev See {ERC721Metadata-tokenURI}.
     */
    function isMinted (uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _gensRegistry[tokenId];
        return string(abi.encodePacked(baseURI, Strings.toString(tokenId), '.json'));
    }

    function _baseURI() internal view override returns (string memory) {
        return currentSeasonalCollectionURI;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}