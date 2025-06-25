// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/MerkleTree.sol";
import "forge-std/console.sol";
import "../src/IMerkleTree.sol";

contract UniversalCaller is Script {
    function run() external {
        address target = vm.envAddress("CONTRACT_ADDRESS");
        string memory func = vm.envString("FUNCTION");

        if (keccak256(bytes(func)) == keccak256(bytes("getTree"))) {
            uint256 arg = vm.envUint("TREEID");
            vm.startBroadcast();
            IMerkleTree(target).getTree(arg);
            vm.stopBroadcast();
        }

        else if (keccak256(bytes(func)) == keccak256(bytes("getTreeSize"))) {
            uint256 arg = vm.envUint("TREEID");
            vm.startBroadcast();
            IMerkleTree(target).getTreeSize(arg);
            vm.stopBroadcast();
        }

        else if(keccak256(bytes(func)) == keccak256(bytes("createTree"))) {
            string memory key = "BYTES32_DATA";
            string memory delimiter = ",";
            bytes32[] memory arr = vm.envBytes32(key, delimiter);

            vm.startBroadcast();
            IMerkleTree(target).createTree(arr);
            vm.stopBroadcast();
        }

        else if(keccak256(bytes(func)) == keccak256(bytes("getProof"))) {
            uint256 arg1 = vm.envUint("TREEID");
            uint256 arg2 = vm.envUint("INDEX");

            vm.startBroadcast();
            IMerkleTree(target).getProof(arg1, arg2);
            vm.stopBroadcast();
        }

        else if(keccak256(bytes(func)) == keccak256(bytes("verify"))) {
            bytes32 arg1 = vm.envBytes32("LEAF");
            bytes32 arg2 = vm.envBytes32("ROOT");
            uint256 arg3 = vm.envUint("INDEX");

            string memory key = "BYTES32_PROOF";
            string memory delimiter = ",";
            bytes32[] memory arg4 = vm.envBytes32(key, delimiter);

            vm.startBroadcast();
            IMerkleTree(target).verify(arg1, arg2, arg3, arg4);
            vm.stopBroadcast();
        }
    }
}