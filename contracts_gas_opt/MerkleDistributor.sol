// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';

contract MerkleDistributor {
    bytes32 public merkleRoot;

    mapping(address => uint256) private _allowListNumMinted;

    /**
     * @dev emitted when an account has claimed some tokens
     */
    event Claimed(address indexed account, uint256 amount);

    /**
     * @dev emitted when the merkle root has changed
     */
    event MerkleRootChanged(bytes32 merkleRoot);


    /**
     * @dev throws when parameters sent by claimer is incorrect
     */
    modifier ableToClaim(address claimer, bytes32[] memory proof) {
        require(onAllowList(claimer, proof), 'Not on allow list');
        _;
    }

    /**
     * @dev sets the merkle root
     */
    function _setAllowList(bytes32 merkleRoot_) internal virtual {
        merkleRoot = merkleRoot_;

        emit MerkleRootChanged(merkleRoot);
    }

    /**
     * @dev adds the number of tokens to the incoming address
     */
    function _setAllowListMinted(address to, uint256 numberOfGens) internal virtual {
        _allowListNumMinted[to] += numberOfGens;

        emit Claimed(to, numberOfGens);
    }

    /**
     * @dev gets the number of tokens from the address
     */
    function getAllowListMinted(address from) public view virtual returns (uint256) {
        return _allowListNumMinted[from];
    }

    /**
     * @dev checks if the claimer has a valid proof
     */
    function onAllowList(address claimer, bytes32[] memory proof) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(claimer));
        return MerkleProof.verify(proof, merkleRoot, leaf);
    }
}