// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Asset} from "../src/asset/Asset.sol";
import {AssetProxy} from "../src/asset/AssetProxy.sol";

/**
 * @title AssetTest
 * @author Yusuf
 * @notice Tests for Asset contract
 */
contract AssetTest is Test {
    address USER1 = makeAddr("TEST_USER_1");
    address USER2 = makeAddr("TEST_USER_2");
    address implementation;
    string uri;
    Asset asset;

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values
    );

    function setUp() public {
        vm.startPrank(msg.sender);
        implementation = address(new Asset());
        uri = "/fake-token-url";
        bytes memory data = abi.encodeCall(Asset.initialize, uri);
        address proxy = address(new AssetProxy(address(implementation), data));
        asset = Asset(proxy);
        vm.stopPrank();
    }

    // ////////////////////////////////////
    // /////     Constructor Tests    /////
    // ////////////////////////////////////

    function test_deploy_succeeds() public {
        vm.startPrank(msg.sender);
        assertEq(asset.uri(1), uri);
        vm.stopPrank();
    }

    function test_mint_reverts_with_ownlyOwner() public {
        uint256 amount = 20e18;
        bytes32 name = bytes32("USDC Coin");
        bytes32 symbol = bytes32("USDC");
        vm.startPrank(USER2);
        vm.expectRevert("Ownable: caller is not the owner");
        asset.mint(USER1, 1, amount, name, symbol, "");
        vm.stopPrank();
    }

    function test_mint_succeeds() public {
        vm.startPrank(msg.sender);
        uint256 amount = 20e18;
        bytes32 name = bytes32("USDC Coin");
        bytes32 symbol = bytes32("USDC");
        asset.mint(USER1, 1, amount, name, symbol, "");
        assertEq(asset.balanceOf(USER1, 1), amount);
        assertEq(asset.nameOf(1), name);
        assertEq(asset.symbolOf(1), symbol);
        vm.stopPrank();
    }

    function test_safeTransferFrom_reverts_with_OnlyOwner() public {
        vm.startPrank(msg.sender);
        uint256 amount = 20e18;
        bytes32 name = bytes32("USDC Coin");
        bytes32 symbol = bytes32("USDC");
        asset.mint(USER1, 1, amount, name, symbol, "");
        vm.stopPrank();
        uint256 amount2 = 4e18;
        vm.startPrank(USER2);
        vm.expectRevert("Ownable: caller is not the owner");
        asset.safeTransferFrom(USER1, USER2, 1, amount2, "");
        vm.stopPrank();
    }

    function test_safeTransferFrom_reverts_with_CallerIsNotApprovedToTransfer() public {
        vm.startPrank(msg.sender);
        uint256 amount = 20e18;
        bytes32 name = bytes32("USDC Coin");
        bytes32 symbol = bytes32("USDC");
        asset.mint(USER1, 1, amount, name, symbol, "");
        uint256 amount2 = 4e18;
        vm.expectRevert(Asset.Asset__CallerIsNotApprovedToTransfer.selector);
        asset.safeTransferFrom(USER1, USER2, 1, amount2, "");
        vm.stopPrank();
    }

    function test_safeTransferFrom_succeeds() public {
        vm.startPrank(msg.sender);
        uint256 amount = 20e18;
        bytes32 name = bytes32("USDC Coin");
        bytes32 symbol = bytes32("USDC");
        asset.mint(USER1, 1, amount, name, symbol, "");
        asset.setApprovalForAll(USER1, true);
        uint256 amount2 = 4e18;
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(msg.sender, USER1, USER2, 1, amount2);
        asset.safeTransferFrom(USER1, USER2, 1, amount2, "");
        assertEq(asset.balanceOf(USER1, 1), amount - amount2);
        assertEq(asset.balanceOf(USER2, 1), amount2);
        vm.stopPrank();
    }

    function test_safeBatchTransferFrom_reverts_with_OnlyOwner() public {
        vm.startPrank(msg.sender);
        uint256 amount = 20e18;
        bytes32 name = bytes32("USDC Coin");
        bytes32 symbol = bytes32("USDC");
        asset.mint(USER1, 1, amount, name, symbol, "");
        vm.stopPrank();
        uint256 amount2 = 4e18;
        vm.startPrank(USER2);
        vm.expectRevert("Ownable: caller is not the owner");
        uint256[] memory assets = new uint256[](3);
        assets[0] = 1;
        assets[1] = 2;
        assets[2] = 3;
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = amount2;
        amounts[1] = amount2;
        amounts[2] = amount2;
        asset.safeBatchTransferFrom(USER1, USER2, assets, amounts, "");
        vm.stopPrank();
    }

    function test_safeBatchTransferFrom_reverts_with_CallerIsNotApprovedToTransfer() public {
        vm.startPrank(msg.sender);
        uint256 amount = 20e18;
        bytes32 name = bytes32("USDC Coin");
        bytes32 symbol = bytes32("USDC");
        asset.mint(USER1, 1, amount, name, symbol, "");
        uint256 amount2 = 4e18;
        vm.expectRevert(Asset.Asset__CallerIsNotApprovedToTransfer.selector);
        uint256[] memory assets = new uint256[](3);
        assets[0] = 1;
        assets[1] = 2;
        assets[2] = 3;
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = amount2;
        amounts[1] = amount2;
        amounts[2] = amount2;
        asset.safeBatchTransferFrom(USER1, USER2, assets, amounts, "");
        vm.stopPrank();
    }

    function test_safeBatchTransferFrom_succeeds() public {
        vm.startPrank(msg.sender);
        uint256 amount = 20e18;
        asset.mint(USER1, 1, amount, bytes32("ASSET 1"), bytes32("AST1"), "");
        asset.mint(USER1, 2, amount, bytes32("ASSET 2"), bytes32("AST2"), "");
        asset.mint(USER1, 3, amount, bytes32("ASSET 3"), bytes32("AST3"), "");
        asset.setApprovalForAll(USER1, true);
        uint256[] memory assets = new uint256[](3);
        assets[0] = 1;
        assets[1] = 2;
        assets[2] = 3;
        uint256[] memory amounts = new uint256[](3);
        uint256 amount2 = 4e18;
        amounts[0] = amount2;
        amounts[1] = amount2;
        amounts[2] = amount2;
        vm.expectEmit(true, true, true, true);
        emit TransferBatch(msg.sender, USER1, USER2, assets, amounts);
        asset.safeBatchTransferFrom(USER1, USER2, assets, amounts, "");
        // 1
        assertEq(asset.balanceOf(USER1, 1), amount - amount2);
        assertEq(asset.balanceOf(USER1, 2), amount - amount2);
        assertEq(asset.balanceOf(USER1, 3), amount - amount2);
        // 2
        assertEq(asset.balanceOf(USER2, 1), amount2);
        assertEq(asset.balanceOf(USER2, 2), amount2);
        assertEq(asset.balanceOf(USER2, 3), amount2);
        vm.stopPrank();
    }

    function test_setApprovalForAll_reverts_with_OnlyOwner() public {
        vm.startPrank(USER2);
        vm.expectRevert("Ownable: caller is not the owner");
        asset.setApprovalForAll(USER1, true);
        vm.stopPrank();
    }

    function test_setApprovalForAll_succeeds() public {
        vm.startPrank(msg.sender);
        vm.expectEmit(true, false, false, false);
        emit ApprovalForAll(USER1, msg.sender, true);
        asset.setApprovalForAll(USER1, true);
        vm.stopPrank();
    }
}
