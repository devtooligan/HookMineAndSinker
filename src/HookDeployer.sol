// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.19;

import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import "forge-std/console.sol";

library HookDeployer {
    using Hooks for IHooks;
    uint256 constant CREATE2_MARKER = 0x00ff00000000000000000000000000000000000000;

    function getPrefix(Hooks.Calls memory calls) public pure returns (uint256 prefix) {
        if (calls.beforeInitialize) prefix |= Hooks.BEFORE_INITIALIZE_FLAG;
        if (calls.afterInitialize) prefix |= Hooks.AFTER_INITIALIZE_FLAG;
        if (calls.beforeModifyPosition) prefix |= Hooks.BEFORE_MODIFY_POSITION_FLAG;
        if (calls.afterModifyPosition) prefix |= Hooks.AFTER_MODIFY_POSITION_FLAG;
        if (calls.beforeSwap) prefix |= Hooks.BEFORE_SWAP_FLAG;
        if (calls.afterSwap) prefix |= Hooks.AFTER_SWAP_FLAG;
        if (calls.beforeDonate) prefix |= Hooks.BEFORE_DONATE_FLAG;
        if (calls.afterDonate) prefix |= Hooks.AFTER_DONATE_FLAG;
    }

    // function mineSaltAndDeployHook(bytes memory initCode, Hooks.Calls memory calls) public returns (address, uint256) {
    //     console.log(getPrefix(calls));
    //     (uint256 salt, address expectedAddress) = mineSaltForHookAddress(initCode, calls);
    //     address newAddress = deployHook(initCode, salt);
    //     require(newAddress == expectedAddress, "HookDeployer: UNEXPECTED_ADDRESS");
    //     return (newAddress, salt);
    // }

    // function mineSaltForHookAddress(bytes memory initCode, Hooks.Calls memory calls) public view returns (uint256 salt, address newAddress) {
    //     return _mineSaltForHookAddress(keccak256(initCode), getPrefix(calls));
    // }

    function deployHook(bytes memory initCode, uint256 salt) public returns (address newAddress) {
        assembly {
            newAddress := create2(0, add(initCode, 0x20), mload(initCode), salt)
        }
    }
}
