//SPDX-License-Identifier: MIT
// Art by @walshe_steve // Copyright © Steve Walshe
// Code by @0xGeeLoko

pragma solidity ^0.8.4;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./MerkleDistributor.sol";

contract GenZero is ERC721A, MerkleDistributor, Ownable, ReentrancyGuard {
    using Strings for string;

    uint256 public constant maxGenZero = 6000;
    uint256 public maxPerMint = 100;
    bool public mintingIsActive = false;
    bool public bioUpgradingIsActive = false;
    bool public publicIsActive = false;


    string public currentSeasonalCollectionURI;

    uint256 public mintPrice;


    // Mapping between tokenId => seasonal collectiong baseURI
    mapping(uint256 => string) private _gensRegistry;

    
    event GenUpdated(uint256 tokenId, string newBaseURI);

    constructor(string memory baseURI) ERC721A("Eternity Complex", "GenZero") {
        currentSeasonalCollectionURI = baseURI;
    }

    modifier ableToMint(uint256 numberOfGens) {
        require(totalSupply() + numberOfGens <= maxGenZero, 'Purchase would exceed Max Token Supply');
        _;
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
    * The ground cost of Morphying, unless free because a Flowty has required age stage
    */
    function setMintCost(uint256 newPrice) public onlyOwner {
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
    * Pause bioupgrading if active, make active if paused
    */
    function flipBioUpgradingState() public onlyOwner {
        bioUpgradingIsActive = !bioUpgradingIsActive;
    }
    /*
    * Pause minting if active, make active if paused
    */
    function flipMintingState() public onlyOwner {
        mintingIsActive = !mintingIsActive;
    }
    /*
    * Pause minting if active, make active if paused
    */
    function flipPublicState() public onlyOwner {
        publicIsActive = !publicIsActive;
    }

    /**
     * arcClaim
     */
    function arcListMint(uint256 numberOfGens, bytes32[] memory merkleProof) 
    external
    ableToClaim(msg.sender, merkleProof)
    ableToMint(numberOfGens)
    nonReentrant 
    {
        require(mintingIsActive, "BioUpgrading must be active to change season");
        require(numberOfGens > 0, "Must mint at least one");
        
        _setAllowListMinted(msg.sender, numberOfGens);
        _safeMint(msg.sender, numberOfGens);
    }

    /**
     * public
     */
    function publicMint(uint256 numberOfGens) 
    external
    payable
    ableToMint(numberOfGens)
    nonReentrant
    {
        require(publicIsActive, "BioUpgrading must be active to change season");
        require(numberOfGens > 0, "Must mint at least one");
        require(numberOfGens <= maxPerMint, 'Exceeded max token purchase');
        require(numberOfGens * mintPrice == msg.value, 'Ether value sent is not correct');
        
       
        _safeMint(msg.sender, numberOfGens);

    }

    /**
    * BioUpgrading existing Gens.
    * Changing current baseURI of a token to a new one, that is current Season topic.
    */
    function bioUpgrade(uint256[] memory tokenIds) public payable {
        require(bioUpgradingIsActive, "BioUpgrading must be active to change season");
        require(tokenIds.length * mintPrice == msg.value, 'Ether value sent is not correct');
        for(uint i = 0; i < tokenIds.length; i++) {
            // Allow bioupgrading for owner only
            if (ownerOf(tokenIds[i]) != msg.sender || !_exists(tokenIds[i])) {
                require(false, "Trying to Bio Upgrade non existing/not owned Gen");
            }
        }
        
        for(uint i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] < maxGenZero, "TokenID would exceed max supply of Gen0");
            _gensRegistry[tokenIds[i]] = currentSeasonalCollectionURI;
            emit GenUpdated(tokenIds[i], currentSeasonalCollectionURI);
        }
    }
    
    /// ERC721 related
    /**
     * @dev See {ERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _gensRegistry[tokenId];
        return string(abi.encodePacked(baseURI, Strings.toString(tokenId), '.json'));
    }

    function _baseURI() internal view override returns (string memory) {
        return currentSeasonalCollectionURI;
    }

}