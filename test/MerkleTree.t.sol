//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {MerkleTree} from "../src/MerkleTree.sol";

contract MerkleTreeTest is Test {
    MerkleTree public merkleTree;

    function setUp() public {
        merkleTree = new MerkleTree();
    }

    function testGetCurrentId() public view {
        assertEq(merkleTree.currentId(), 0);
    }

    function testFuzzCreateTree(bytes32[] calldata data) public {
        vm.assume(_isPowerOfTwo(data.length) && data.length > 1);

        uint256 treeId = merkleTree.createTree(data);

        uint256 length = data.length;
        assertEq(merkleTree.getTreeSize(merkleTree.currentId() - 1), length);

        bytes32[] memory tree = merkleTree.getTree(merkleTree.currentId() - 1);
        assertEq(tree.length, length * 2 - 1);

        for (uint256 i = 0; i < length; i++) {
            assertEq(tree[i], data[i]);
        }

        uint256 curretId = merkleTree.currentId();
        assertEq(treeId, curretId - 1);
        assertEq(merkleTree.currentId(), 1);
    }

    function testFuzzVerify(bytes32[] memory data) public {
        vm.assume(_isPowerOfTwo(data.length) && data.length > 1);

        uint256 treeId = merkleTree.createTree(data);

        bytes32[] memory tree = merkleTree.getTree(treeId);
        bytes32 root = tree[tree.length - 1];

        for (uint256 i = 0; i < data.length; i++) {
            bytes32[] memory proof = merkleTree.getProof(treeId, i);
            assertEq(merkleTree.verify(data[i], root, i, proof), true);
        }
    }

    function testRevertsCreateTree() public {
        bytes32[] memory _data = new bytes32[](0);

        vm.expectRevert(bytes("the length should be 2^n"));
        merkleTree.createTree(_data);

        _data = new bytes32[](1);
        vm.expectRevert(bytes("the length should be 2^n"));
        merkleTree.createTree(_data);

        _data = new bytes32[](3);
        vm.expectRevert(bytes("the length should be 2^n"));
        merkleTree.createTree(_data);
    }

    function testFuzzRevertsGetProof(
        uint256 id,
        bytes32[] calldata data
    ) public {
        vm.assume(_isPowerOfTwo(data.length) && data.length > 1);

        vm.expectRevert(bytes("Empty tree"));
        merkleTree.getProof(id, 0);

        uint256 treeId = merkleTree.createTree(data);
        vm.expectRevert(bytes("Invalid leaf index"));
        merkleTree.getProof(treeId, data.length);
    }

    function testFuzzVerifyWrongProof(bytes32[] memory data) public {
        vm.assume(_isPowerOfTwo(data.length) && data.length > 1);

        uint256 treeId = merkleTree.createTree(data);
        bytes32[] memory tree = merkleTree.getTree(treeId);
        bytes32 root = tree[tree.length - 1];

        for (uint256 i = 0; i < data.length; i++) {
            bytes32[] memory proof = merkleTree.getProof(treeId, i);

            proof[0] = bytes32(uint256(proof[0]) + 1);

            assertEq(merkleTree.verify(data[i], root, i, proof), false);
        }
    }

    function testFuzzDifferentRoot(bytes32[] calldata data1) public {
        vm.assume(_isPowerOfTwo(data1.length) && data1.length > 1);

        bytes32[] memory data2 = data1;

        data2[0] = bytes32(uint256(data2[0]) + 1);

        uint256 tree1 = merkleTree.createTree(data1);
        uint256 tree2 = merkleTree.createTree(data2);

        bytes32 root1 = merkleTree.getTree(tree1)[data1.length * 2 - 2];
        bytes32 root2 = merkleTree.getTree(tree2)[data2.length * 2 - 2];

        assertTrue(root1 != root2);
    }

    function testFuzzSameData(bytes32[] calldata data) public {
        vm.assume(_isPowerOfTwo(data.length) && data.length > 1);

        uint256 treeIdFirst = merkleTree.createTree(data);
        uint256 treeIdSecond = merkleTree.createTree(data);

        for(uint256 i = 0; i < data.length; i++) {
            bytes32[] memory proof1 = merkleTree.getProof(treeIdFirst, i);
            bytes32[] memory proof2 = merkleTree.getProof(treeIdSecond, i);

            for(uint256 j = 0; j < proof1.length; j++) {
                assertEq(proof1[j], proof2[j]);
            }
        }
    }

    function testFuzzEqualRoots(bytes32[] calldata data) public {
        vm.assume(_isPowerOfTwo(data.length) && data.length > 1);

        uint256 treeIdFirst = merkleTree.createTree(data);
        uint256 treeIdSecond = merkleTree.createTree(data);

        bytes32 rootFirst = merkleTree.getTree(treeIdFirst)[data.length * 2 - 2];
        bytes32 rootSecond = merkleTree.getTree(treeIdSecond)[data.length * 2 - 2];

        assertEq(rootFirst, rootSecond);
    }

    function testMaxSize() public {
        uint256 size = 512;
        bytes32[] memory data = new bytes32[](size);

        for(uint256 i = 0; i < size; i++) {
            data[i] = keccak256(abi.encodePacked(i));
        }

        uint256 treeId = merkleTree.createTree(data);

        assertEq(merkleTree.getTreeSize(treeId), size);

        bytes32[] memory tree = merkleTree.getTree(treeId);
        assertEq(tree.length, data.length * 2 - 1);

        assertTrue(tree[tree.length - 1] != bytes32(0));
    }

    function _isPowerOfTwo(uint256 _x) internal pure returns (bool) {
        return _x > 0 && (_x & (_x - 1)) == 0;
    }
}
