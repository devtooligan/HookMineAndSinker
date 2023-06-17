// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract SaltMinerTest is Test {
    /// @dev Address of the SaltMiner contract.
    ISaltMiner public saltMiner;

    /// @dev Setup the testing environment.
    function setUp() public {
        saltMiner = ISaltMiner(HuffDeployer.deploy("SaltMiner"));
    }

    /// @dev Ensure that you can set and get the value.
    function testMineSalt() public {
        (uint256 salt, address newAddress) = saltMiner.mineSalt(keccak256("myCode"), uint(0x004400000000000000000000000000000000000000), address(this));
        console.log(salt);
        console.log(newAddress);
    }
}

interface ISaltMiner {
    function mineSalt(bytes32 initCodeHash,uint256 prefix, address deployer) external view returns (uint256,address);
}
