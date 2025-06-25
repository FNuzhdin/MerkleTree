//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/// @title MerkleTree
/// @author FNuzhdin
/// @notice Implements Merkle Tree creation, proof generation, and verification.
/// @dev This contract supports multiple Merkle trees, each identified by an incrementing ID.
contract MerkleTree {
    /// @notice Number of children per parent node (binary tree)
    uint256 constant STEP = 2;

    uint256 public currentId;
    mapping(uint256 id => bytes32[] hashes) public trees;

    /// @notice Mapping from tree ID to the number of leaves in the tree
    mapping(uint256 id => uint256) public treeSizes;

    /// @notice Get the full array of hashes for a specific Merkle tree by its ID.
    /// @param id The Merkle tree identifier.
    /// @return The array of hashes (leaf nodes first, then internal nodes, then root).
    function getTree(uint256 id) public view returns (bytes32[] memory) {
        return trees[id];
    }

    /// @notice Get the number of leaves for a specific Merkle tree by its ID.
    /// @param id The Merkle tree identifier.
    /// @return The number of leaves in the tree.
    function getTreeSize(uint256 id) public view returns (uint256) {
        return treeSizes[id];
    }

    /// @notice Create a new Merkle tree from an array of leaf data.
    /// @dev The input array length must be a power of two and greater than 1.
    /// @param _data Array of leaf hashes to build the tree from.
    /// @return id The unique identifier of the created Merkle tree.
    function createTree(bytes32[] calldata _data) public returns (uint256) {
        uint256 _dataLength = _data.length;
        require(_isPowerOfTwo(_dataLength) && _dataLength != 1, "the length should be 2^n");

        bytes32[] storage tree = trees[currentId];
        treeSizes[currentId] = _dataLength;

        // Initialize the tree with the leaf nodes
        for (uint256 i = 0; i < _dataLength; i++) {
            tree.push(_data[i]);
        }

        uint256 n = _dataLength;
        uint256 offset = 0;

        // Build upper levels of the Merkle tree
        while (n > 1) {
            uint256 newOffset = offset + n;
            for (uint256 i = 0; i < n; i += STEP) {
                bytes32 newHash = keccak256(
                    abi.encodePacked(tree[offset + i], tree[offset + i + 1])
                );
                tree.push(newHash);
            }
            offset = newOffset;
            n = n / STEP;
        }
        currentId++;

        return currentId - 1;
    }

    /// @notice Generate a Merkle proof for a given leaf in a specific tree.
    /// @param id The Merkle tree identifier.
    /// @param leafIndex The index of the leaf (starting from 0).
    /// @return proof Array of sibling hashes needed to reconstruct the Merkle root.
    function getProof(
        uint256 id,
        uint256 leafIndex
    ) public view returns (bytes32[] memory proof) {
        bytes32[] storage tree = trees[id];
        uint256 leafCount = treeSizes[id];

        require(leafCount > 0, "Empty tree");
        require(leafIndex < leafCount, "Invalid leaf index");

        uint256 levelCount = 0;
        uint256 tmp = leafCount;
        while (tmp > 1) {
            levelCount++;
            tmp /= 2;
        }
        proof = new bytes32[](levelCount);

        uint256 n = leafCount;
        uint256 index = leafIndex;
        uint256 offset = 0;

        for (uint256 level = 0; n > 1; level++) {
            uint256 siblingIndex = index % 2 == 0 ? index + 1 : index - 1;
            proof[level] = tree[offset + siblingIndex];

            offset += n;
            index /= 2;
            n /= 2;
        }
    }

    /// @notice Verify a Merkle proof for a given leaf and root.
    /// @param leaf The hash of the leaf to prove.
    /// @param root The Merkle root to verify against.
    /// @param index The index of the leaf in the tree.
    /// @param proof The array of sibling hashes to reconstruct the root.
    /// @return isValid True if the proof is valid and the leaf is part of the tree with given root.
    function verify(
        bytes32 leaf,
        bytes32 root,
        uint256 index,
        bytes32[] memory proof
    ) public pure returns (bool) {
        bytes32 hash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, proof[i]));
            } else {
                hash = keccak256(abi.encodePacked(proof[i], hash));
            }
            index /= 2;
        }
        return hash == root;
    }

    /// @notice Check if a given number is a power of two.
    /// @dev Internal utility function.
    /// @param _x The number to check.
    /// @return True if `_x` is a power of two, false otherwise.
    function _isPowerOfTwo(uint256 _x) internal pure returns (bool) {
        return _x > 0 && (_x & (_x - 1)) == 0;
    }
}
