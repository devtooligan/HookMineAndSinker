// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import "foundry-huff/HuffDeployer.sol";
import {HookDeployer} from "../src/HookDeployer.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {PoolManager} from "@uniswap/v4-core/contracts/PoolManager.sol";
import {LimitOrder} from "@uniswap/v4-periphery/contracts/hooks/examples/LimitOrder.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract SaltMinerTest is Test {
    ISaltMiner public saltMiner;
    PoolManager manager;

    /// @dev Setup the testing environment.
    function setUp() public {
        saltMiner = ISaltMiner(HuffDeployer.deploy("SaltMiner"));
        manager = new PoolManager(500000);

    }

    /// @dev Ensure that you can set and get the value.
    function testMineSalt__LimitOrder() public {
        // LimitOrder
        bytes memory initCode = abi.encodePacked(type(LimitOrder).creationCode, abi.encode(manager));
        bytes32 initCodeHash = keccak256(initCode);
        uint prefix = HookDeployer.getPrefix(Hooks.Calls({
            beforeInitialize: false,
            afterInitialize: true,
            beforeModifyPosition: false,
            afterModifyPosition: false,
            beforeSwap: false,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false
        }));

        // uint start = gasleft();
        (uint256 salt, address expectedAddress) = saltMiner.mineSalt(address(this), prefix,initCodeHash );
        console.log("salt: %s", salt);
        address actualAddress = HookDeployer.deployHook(initCode, salt);
        assertEq(actualAddress, expectedAddress);
    }
}

interface ISaltMiner {
    function mineSalt( address deployer,uint256 prefix,bytes32 initCodeHash) external view returns (uint256,address);
}
