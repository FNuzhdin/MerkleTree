# MerkleTree

**MerkleTree** is a Solidity project that implements a Merkle Tree data structure and a set of scripts for interacting with it using Foundry.

## Main Components

### Contracts

- [`src/MerkleTree.sol`](src/MerkleTree.sol)  
  The main Solidity implementation of the Merkle Tree structure. The contract allows you to create new trees from an array of hashes (`bytes32[]`), store them, retrieve Merkle roots, and verify proofs of element inclusion.

- [`src/IMerkleTree.sol`](src/IMerkleTree.sol)  
  An interface for interacting with the MerkleTree contract: defines the core functions for external calls.

### Scripts

- [`script/Deploy.s.sol`](script/Deploy.s.sol)  
  Script for deploying the MerkleTree contract to a test or local network.

- [`script/CreateTree.s.sol`](script/CreateTree.s.sol)  
  Script for creating a new Merkle tree on an already deployed contract.

- [`script/UniversalCaller.s.sol`](script/UniversalCaller.s.sol)  
  A universal script for low-level calls to any functions of the MerkleTree contract with the ability to pass various parameters via environment variables. Suitable for experiments and automation.

### Tests

- [`test/MerkleTree.t.sol`](test/MerkleTree.t.sol)  
  Unit tests written in Foundry, verifying the correct operation of MerkleTree: creating trees, computing roots, validating proofs, and edge cases.

## Quick Start

1. **Install Foundry:**  
   See the [official documentation](https://book.getfoundry.sh/) for installation instructions.

2. **Install dependencies:**  
   ```sh
   forge install
   ```

3. **Deploy the contract:**  
   ```sh
   forge script script/Deploy.s.sol --broadcast --rpc-url <RPC_URL>
   ```

4. **Create a Merkle tree:**  
   Edit or use the `CreateTree.s.sol` script to add a new tree.

5. **Run tests:**  
   ```sh
   forge test
   ```

## Using UniversalCaller

The `UniversalCaller.s.sol` script lets you call any contract function via a low-level call. Parameters (contract address, function name, data) are passed through environment variables.

Example:
```sh
export CONTRACT_ADDRESS=0x...          # MerkleTree contract address
export FUNCTION=createTree             # function name to call
export BYTES32_DATA=0x123...,0x456...  # data for the function
forge script script/UniversalCaller.s.sol --broadcast --rpc-url <RPC_URL>
```

## Project Structure

- `src/` — contract sources and interfaces
- `test/` — Foundry tests
- `script/` — deployment and interaction scripts
- `lib/`, `broadcast/`, `out/`, `cache/` — service directories (usually git-ignored)

## License

MIT

---

**Author:** [FNuzhdin](https://github.com/FNuzhdin)  
Pull requests and suggestions are welcome!