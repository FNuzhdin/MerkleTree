//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMerkleTree {
    function getTree(uint256 id) external view returns (bytes32[] memory);

    function getTreeSize(uint256 id) external view returns (uint256);

    function createTree(bytes32[] calldata _data) external returns (uint256);

    function getProof(
        uint256 id,
        uint256 leafIndex
    ) external view returns (bytes32[] memory proof);

    function verify(
        bytes32 leaf,
        bytes32 root,
        uint256 index,
        bytes32[] memory proof
    ) external pure returns (bool);
}
