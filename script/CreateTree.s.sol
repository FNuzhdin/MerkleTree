// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/MerkleTree.sol";
import "../src/IMerkleTree.sol";
import "forge-std/console.sol";

contract CreateTree is Script {
    function run() external {
        address target = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

        bytes32[] memory data = new bytes32[](4);
        data[0] = keccak256(bytes("Hi"));
        data[1] = keccak256(bytes("MyName"));
        data[2] = keccak256(bytes("Script"));
        data[3] = keccak256(bytes("onSol"));

        vm.startBroadcast();
        uint256 id = IMerkleTree(target).createTree(data);
        vm.stopBroadcast();

        console.log(id);
    }
}
