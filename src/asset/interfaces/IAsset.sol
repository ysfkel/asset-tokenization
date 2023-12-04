// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/**
 * @title IAsset
 * @author Yusuf
 * @notice Defines interface for Asset.
 */
interface IAsset {
    /**
     *
     * @param to receiver address
     * @param id asset id to mint
     * @param amount asset amount to mint
     * @param name aasset name
     * @param symbol asset symbol
     * @param data -refer ERC1155 _mint
     */
    function mint(address to, uint256 id, uint256 amount, bytes32 name, bytes32 symbol, bytes calldata data) external;

    /**
     *
     * @param id asset id
     * @return returns asset name in bytes32
     */
    function nameOf(uint256 id) external view returns (bytes32);

    /**
     *
     * @param id asset id
     * @return returns asset symbol in bytes32
     */
    function symbolOf(uint256 id) external view returns (bytes32);

    /**
     * @notice  locks assets to the controller address
     * @param from assets owner address
     * @param ids asset id
     * @param amounts amount to transfer
     * @param data -refer ERC1155 _mint
     */
    function lock(address from, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;

    /**
     * @notice  used to transfer consumed asset back to the owner
     * @param to receivre address
     * @param ids asset id
     * @param amounts amount to transfer
     * @param data -refer ERC1155 _mint
     */
    function unlock(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;
}
