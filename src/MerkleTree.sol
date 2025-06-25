//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MerkleTree {
    uint256 constant STEP = 2;

    uint256 public currentId;
    mapping(uint256 id => bytes32[] hashes) public trees;
    mapping(uint256 id => uint256) public treeSizes;

    function getTree(uint256 id) public view returns (bytes32[] memory) {
        return trees[id];
    }

    function getTreeSize(uint256 id) public view returns (uint256) {
        return treeSizes[id];
    }

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

    function _isPowerOfTwo(uint256 _x) internal pure returns (bool) {
        return _x > 0 && (_x & (_x - 1)) == 0;
    }
}
