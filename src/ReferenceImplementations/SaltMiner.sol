// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.15;

contract HookMineAndSinker {
    uint256 constant PREFIX_MASK = 0x00ff00000000000000000000000000000000000000;

    /// @notice Mine a salt that will produce a hook address with the given prefix
    /// @dev Solidity implementation
    /// @param initCodeHash The keccak hash of the initCode of the contract to be deployed
    /// @param prefix The prefix of the hook address
    /// @return salt The salt that will produce a hook address with the given prefix
    function mineSalt(bytes32 initCodeHash, uint256 prefix, address deployer)
        public
        view
        returns (uint256 salt, address newAddress)
    {
        bool valid;
        while (true) {
            newAddress =
                address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, initCodeHash)))));

            assembly {
                valid := eq(and(newAddress, 0x00ff00000000000000000000000000000000000000), prefix)
            }
            if (valid) {
                break;
            }

            salt = gasleft();
        }
    }

    /// @notice Mine a salt that will produce a hook address with the given prefix
    /// @dev Solidity with all inline assembly implementation
    /// @param initCodeHash The keccak hash of the initCode of the contract to be deployed
    /// @param prefix The prefix of the hook address
    /// @return salt The salt that will produce a hook address with the given prefix
    function mineSaltASM(bytes32 initCodeHash, uint256 prefix, address deployer)
        public
        view
        returns (uint256 salt, address newAddress)
    {
        assembly {
            // Preserve free memory pointer
            let freeMemPtr := mload(0x40)

            // Setup memory
            //0x00: 00 00 00 00 00 00 00 00 00 00 00 ff |-- address(this) -------------- |
            //0x20: |------------------------ salt ------------------------------------- |
            //0x40: |----------------- keccak256(initCode) ----------------------------- |
            mstore(0x00, deployer)
            mstore8(0x0b, 0xff)
            mstore(0x20, salt)
            mstore(0x40, initCodeHash)

            let valid
            for {} 0x01 {} {
                newAddress := keccak256(0x0b, 0x55)
                valid := eq(and(newAddress, PREFIX_MASK), prefix)
                if valid { break }
                salt := gas()
                mstore(0x20, salt)
            }

            // Restore free memory pointer
            mstore(0x40, freeMemPtr)
        }
    }
}
