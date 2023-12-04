// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Asset} from "../src/asset/Asset.sol";
import {AssetProxy} from "../src/asset/AssetProxy.sol";
import {AssetController, AssetControllerBase} from "../src/asset/AssetController.sol";
import {AssetControllerProxy} from "../src/asset/AssetControllerProxy.sol";

/**
 * @title AssetControllerTest
 * @author Yusuf
 * @notice Tests for Asset contract
 */
contract AssetControllerTest is Test {
    address USER1 = makeAddr("TEST_USER_1");
    address USER2 = makeAddr("TEST_USER_2");
    address USER3 = makeAddr("TEST_USER_3");
    address USER4 = makeAddr("TEST_USER_4");
    address USER5 = makeAddr("TEST_USER_5");

    address asset_implementation = address(new Asset());
    address assetProxy;
    address implentation;
    Asset asset;
    AssetController controller;

    event BatchTransfer(address indexed from, address indexed to, uint256[] assetIds, uint256[] amounts);
    event Transfer(address indexed from, address indexed to, uint256 indexed assetId, uint256 amount);
    event Consume(address indexed sender, uint256 indexed assetId, uint256[] contentIds, uint256[] amounts);
    event Mint(
        address indexed sender, uint256 indexed assetId, uint256 amount, uint256[] contentIds, uint256[] amounts
    );

    function setUp() public {
        vm.startPrank(msg.sender);
        address assetAddress = address(new Asset());
        implentation = address(new AssetController());
        string memory tokenUri = "/fake-token-url";
        assetProxy = address(new AssetProxy(address(assetAddress), abi.encodeCall(Asset.initialize, tokenUri)));
        asset = Asset(assetProxy);
        bytes memory data = abi.encodeCall(AssetController.initialize, (assetProxy, 10));
        address controllerProxy = address(new AssetControllerProxy(implentation, data));
        controller = AssetController(controllerProxy);
        vm.stopPrank();
    }

    // ////////////////////////////////////
    // /////     Constructor Tests    /////
    // ////////////////////////////////////

    function test_deploy_succeeds() public {
        vm.startPrank(msg.sender);
        assertEq(controller.assets(), assetProxy);
        assertEq(controller.assetCount(), 0);
        assertEq(controller.maxContentPerTransaction(), 10);
        vm.stopPrank();
    }

    function test_mint_reverts_with__ZeroBalance() public {
        vm.startPrank(msg.sender);
        uint256[] memory contentIds = new uint256[](0);
        uint256[] memory amounts = new uint256[](0);
        vm.expectRevert(AssetController.AssetController__ZeroAmount.selector);
        controller.mint(0, bytes32("Fabric"), bytes32("FAB"), contentIds, amounts, bytes32("external_ref"), "");
        vm.stopPrank();
    }

    function test_mint_reverts_with_CallerIsNotOwner() public {
        vm.startPrank(msg.sender);
        uint256[] memory contentIds = new uint256[](0);
        uint256[] memory amounts = new uint256[](0);
        vm.expectRevert("Ownable: caller is not the owner");
        controller.mint(500e18, bytes32("Fabric"), bytes32("FAB"), contentIds, amounts, bytes32("external_ref"), "");
        vm.stopPrank();
    }

    function test_mint_with_nocontents_succeeds() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        uint256[] memory contentIds = new uint256[](0);
        uint256[] memory amounts = new uint256[](0);
        assertEq(contentIds.length, 0);
        vm.expectEmit(true, true, true, true);
        emit Mint(msg.sender, 1, 500e18, contentIds, amounts);
        controller.mint(500e18, bytes32("Fabric"), bytes32("FAB"), contentIds, amounts, bytes32("external_ref"), "");
        vm.stopPrank();
    }

    function test_mint_sets_external_content_ref() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        uint256[] memory contentIds = new uint256[](0);
        uint256[] memory amounts = new uint256[](0);
        assertEq(contentIds.length, 0);
        vm.expectEmit(true, true, true, true);
        emit Mint(msg.sender, 1, 500e18, contentIds, amounts);
        controller.mint(500e18, bytes32("Fabric"), bytes32("FAB"), contentIds, amounts, bytes32("external_ref"), "");
        assertEq(controller.getAssetExternalContentRef(1), bytes32("external_ref"));
        vm.stopPrank();
    }

    function test_mint_reverts_with__ZeroAmount() public {
        vm.startPrank(msg.sender);
        vm.expectRevert(AssetController.AssetController__ZeroAmount.selector);
        controller.mint(
            0, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        vm.stopPrank();
    }

    function test_mint_with_contents__reverts_with__ContentIdsAmountsMismatch() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();
        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](3);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 400e18;
        amounts[1] = 400e18;

        vm.startPrank(USER3);
        vm.expectRevert(
            abi.encodePacked(
                AssetControllerBase.AssetController__ContentIdsAmountsMismatch.selector,
                contentIds.length,
                amounts.length
            )
        );
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        vm.stopPrank();
    }

    function test_mint_with_contents__reverts_with__ExceededAllowedContetIdLengthPerTransaction() public {
        vm.startPrank(msg.sender);
        controller.setMaxContentPerTransaction(1);
        asset.transferOwnership(address(controller));
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 400e18;
        amounts[1] = 400e18;

        vm.startPrank(USER3);
        vm.expectRevert(AssetControllerBase.AssetController__ExceedsMaxAllowedContentIdPerTransaction.selector);
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        vm.stopPrank();
    }

    function test_mint_with_contents__reverts_with__ZeroAmount() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 400e18;
        amounts[1] = 0;

        vm.startPrank(USER3);
        vm.expectRevert(abi.encodeWithSelector(AssetControllerBase.AssetController__ZeroContentAmount.selector, 2));
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        vm.stopPrank();
    }

    function test_mint_with_contents__reverts_with__UnknownAsset() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 10;
        amounts[0] = 400e18;
        amounts[1] = 400e18;

        vm.startPrank(USER3);
        vm.expectRevert(
            abi.encodeWithSelector(AssetControllerBase.AssetController__UnknownAsset.selector, contentIds[1])
        );
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        vm.stopPrank();
    }

    function test_mint_with_contents__reverts_with__InsufficientAssetBalance() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 400e18;
        amounts[1] = 400e18;

        vm.startPrank(USER3);
        controller.transfer(USER2, 1, 500e18, "");
        vm.expectRevert("ERC1155: insufficient balance for transfer");
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        vm.stopPrank();
    }

    function test_mint_with_contents__succeeds() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        controller.setMaxContentPerTransaction(10);
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 400e18;
        amounts[1] = 300e18;

        vm.startPrank(USER3);
        vm.expectEmit(true, true, true, true);
        emit Consume(USER3, 3, contentIds, amounts);
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        assertEq(asset.balanceOf(address(controller), 1), 400e18);
        assertEq(asset.balanceOf(address(controller), 2), 300e18);
        assertEq(asset.balanceOf(USER3, 1), 100e18);
        assertEq(asset.balanceOf(USER3, 2), 200e18);
        uint256[] memory content = controller.getAssetContent(3);
        assertEq(content[0], 1);
        assertEq(content[1], 2);
        uint256 contentAmount1 = controller.getAssetContentAmount(3, 1);
        uint256 contentAmount2 = controller.getAssetContentAmount(3, 2);
        assertEq(contentAmount1, 400e18);
        assertEq(contentAmount2, 300e18);
        uint256 contentIndex1 = controller.getAssetContentIndex(3, 1);
        uint256 contentIndex2 = controller.getAssetContentIndex(3, 2);
        assertEq(contentIndex1, 0);
        assertEq(contentIndex2, 1);
        vm.stopPrank();
    }

    function test_reduceContentAmounts__reverts_with_NotAssetOwner() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);
        contentIds[0] = 1;
        amounts[0] = 400e18;

        vm.startPrank(USER3);
        vm.expectRevert(AssetController.AssetController__NotAssetOwner.selector);
        controller.reduceContentAmounts(2, contentIds, new uint256[](1), bytes(""));
        vm.stopPrank();
    }

    function test_reduceContentAmounts__reverts_with__InputContentIdsExceedsStoredContentCount() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 400e18;
        amounts[1] = 400e18;

        vm.startPrank(USER2);
        vm.expectRevert(AssetControllerBase.AssetController__InputContentIdsExceedsStoredContentCount.selector);
        controller.reduceContentAmounts(2, contentIds, amounts, bytes(""));
        vm.stopPrank();
    }

    function test_reduceContentAmounts__reverts_with_ContentIdsAmountsMismatch() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 400e18;
        amounts[1] = 300e18;

        vm.startPrank(USER3);
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        amounts[0] = 200e18;
        amounts[1] = 100e18;
        vm.expectRevert(
            abi.encodePacked(
                AssetControllerBase.AssetController__ContentIdsAmountsMismatch.selector, contentIds.length, uint256(1)
            )
        );
        controller.reduceContentAmounts(3, contentIds, new uint256[](1), bytes(""));
        vm.stopPrank();
    }

    function test_reduceContentAmounts__succeeds() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 400e18;
        amounts[1] = 300e18;

        vm.startPrank(USER3);
        assertEq(asset.isApprovedForAll(USER3, address(controller)), true);
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        assertEq(controller.getAssetContentAmount(3, 1), 400 ether);
        assertEq(controller.getAssetContentAmount(3, 2), 300 ether);
        assertEq(asset.balanceOf(address(controller), 1), 400 ether);
        assertEq(asset.balanceOf(address(controller), 2), 300 ether);

        amounts[0] = 200e18;
        amounts[1] = 200e18;
        controller.reduceContentAmounts(3, contentIds, amounts, bytes(""));
        assertEq(controller.getAssetContentAmount(3, 1), 200 ether);
        assertEq(controller.getAssetContentAmount(3, 2), 100 ether);
        //
        assertEq(controller.getAssetContentIndex(3, 1), 0);
        assertEq(controller.getAssetContentIndex(3, 2), 1);
        //
        assertEq(asset.balanceOf(address(controller), 1), 200 ether);
        assertEq(asset.balanceOf(address(controller), 2), 100 ether);
        vm.stopPrank();
    }

    function test_reduceContentAmounts__reverts_with_AmountGreaterThanStoredAmount() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 400e18;
        amounts[1] = 300e18;

        vm.startPrank(USER3);
        assertEq(asset.isApprovedForAll(USER3, address(controller)), true);
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");

        amounts[0] = 200e18;
        amounts[1] = 301e18;
        vm.expectRevert(
            abi.encodePacked(
                AssetControllerBase.AssetController__AmountGreaterThanStoredAmount.selector,
                uint256(2),
                uint256(300 ether),
                uint256(301 ether)
            )
        );
        controller.reduceContentAmounts(3, contentIds, amounts, bytes(""));

        vm.stopPrank();
    }

    function test_reduceContentAmounts__reverts_with_InputContentIdsExceedsStoredContentCount() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 400e18;
        amounts[1] = 300e18;

        vm.startPrank(USER3);
        assertEq(asset.isApprovedForAll(USER3, address(controller)), true);
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        assertEq(controller.getAssetContentAmount(3, 1), 400 ether);
        assertEq(controller.getAssetContentAmount(3, 2), 300 ether);
        assertEq(asset.balanceOf(address(controller), 1), 400 ether);
        assertEq(asset.balanceOf(address(controller), 2), 300 ether);

        amounts[0] = 200e18;
        amounts[1] = 200e18;
        controller.reduceContentAmounts(3, contentIds, amounts, bytes(""));

        amounts[0] = 200e18;
        amounts[1] = 100e18;
        controller.reduceContentAmounts(3, contentIds, amounts, bytes(""));
        vm.expectRevert(AssetControllerBase.AssetController__InputContentIdsExceedsStoredContentCount.selector);
        controller.reduceContentAmounts(3, contentIds, amounts, bytes(""));
        vm.stopPrank();
    }

    function test_reduceContentAmounts__succeeds_and_updates_AssetContentAmount_and_AssetContentIndex() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 400e18;
        amounts[1] = 300e18;

        vm.startPrank(USER3);
        assertEq(asset.isApprovedForAll(USER3, address(controller)), true);
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        assertEq(controller.getAssetContentAmount(3, 1), 400 ether);
        assertEq(controller.getAssetContentAmount(3, 2), 300 ether);
        assertEq(asset.balanceOf(address(controller), 1), 400 ether);
        assertEq(asset.balanceOf(address(controller), 2), 300 ether);

        amounts[0] = 200e18;
        amounts[1] = 200e18;
        controller.reduceContentAmounts(3, contentIds, amounts, bytes(""));
        assertEq(controller.getAssetContentAmount(3, 1), 200 ether);
        assertEq(controller.getAssetContentAmount(3, 2), 100 ether);
        //
        assertEq(controller.getAssetContentIndex(3, 1), 0);
        assertEq(controller.getAssetContentIndex(3, 2), 1);
        //
        assertEq(asset.balanceOf(address(controller), 1), 200 ether);
        assertEq(asset.balanceOf(address(controller), 2), 100 ether);

        amounts[0] = 200e18;
        amounts[1] = 100e18;
        controller.reduceContentAmounts(3, contentIds, amounts, bytes(""));
        assertEq(controller.getAssetContentAmount(3, 1), 0 ether);
        assertEq(controller.getAssetContentAmount(3, 2), 0 ether);
        //
        assertEq(controller.getAssetContentIndex(3, 1), 1);
        assertEq(controller.getAssetContentIndex(3, 2), 0);
        //
        assertEq(asset.balanceOf(address(controller), 1), 0 ether);
        assertEq(asset.balanceOf(address(controller), 2), 0 ether);
        vm.stopPrank();
    }

    function test_reduceContentAmounts_remove_all__succeeds_and_updates_removes_zero_Amount_content() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();
        uint256 _mintAmount = 1000 ether;
        vm.startPrank(USER1);
        controller.mint(
            _mintAmount,
            bytes32("Fabric"),
            bytes32("FAB"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 1, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            _mintAmount,
            bytes32("Fabric2"),
            bytes32("FAB2"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 2, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER3);
        controller.mint(
            _mintAmount,
            bytes32("Fabric3"),
            bytes32("FAB3"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 3, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER4);
        controller.mint(
            _mintAmount,
            bytes32("Fabric4"),
            bytes32("FAB4"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 4, _mintAmount, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](4);
        uint256[] memory amounts = new uint256[](4);
        contentIds[0] = 1;
        contentIds[1] = 2;
        contentIds[2] = 3;
        contentIds[3] = 4;

        amounts[0] = _mintAmount;
        amounts[1] = _mintAmount;
        amounts[2] = _mintAmount;
        amounts[3] = _mintAmount;

        vm.startPrank(USER5);
        assertEq(asset.isApprovedForAll(USER5, address(controller)), true);
        controller.mint(
            _mintAmount, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), ""
        );
        // check consumed amounts
        assertEq(controller.getAssetContentAmount(5, 1), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 2), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 3), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 4), _mintAmount);
        //
        assertEq(controller.getAssetContentIndex(5, 1), 0);
        assertEq(controller.getAssetContentIndex(5, 2), 1);
        assertEq(controller.getAssetContentIndex(5, 3), 2);
        assertEq(controller.getAssetContentIndex(5, 4), 3);
        // check locked amounts
        assertEq(asset.balanceOf(address(controller), 1), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 2), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 3), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 4), _mintAmount);
        assertEq(controller.getContentCount(5), 4);

        contentIds = new uint256[](4);
        amounts = new uint256[](4);
        contentIds[0] = 2; // remove // origia
        contentIds[1] = 1;
        contentIds[2] = 4; // remove
        contentIds[3] = 3;

        amounts[0] = _mintAmount; //4
        amounts[1] = _mintAmount; //3
        amounts[2] = _mintAmount; //2
        amounts[3] = _mintAmount; //1
        assertEq(controller.getContentLength(5), 4);
        assertEq(controller.getContentLength(5), controller.getContentCount(5));
        controller.reduceContentAmounts(5, contentIds, amounts, bytes(""));
        assertEq(controller.getContentLength(5), 0);
        // // // //

        assertEq(controller.getAssetContentIndex(5, 2), 3); // 4
        assertEq(controller.getAssetContentIndex(5, 1), 2); // 3
        assertEq(controller.getAssetContentIndex(5, 4), 1); // 2
        assertEq(controller.getAssetContentIndex(5, 3), 0); // 1

        assertEq(controller.getAssetContentAmount(5, 1), 0 ether);
        assertEq(controller.getAssetContentAmount(5, 2), 0 ether);
        assertEq(controller.getAssetContentAmount(5, 3), 0 ether);
        assertEq(controller.getAssetContentAmount(5, 4), 0 ether);

        assertEq(asset.balanceOf(address(controller), 1), 0 ether);
        assertEq(asset.balanceOf(address(controller), 1), 0 ether);
        assertEq(asset.balanceOf(address(controller), 1), 0 ether);
        assertEq(asset.balanceOf(address(controller), 1), 0 ether);
        vm.stopPrank();
    }

    function test_reduceContentAmounts_remove_one__succeeds_and_updates_removes_zero_Amount_content() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();
        uint256 _mintAmount = 1000 ether;
        vm.startPrank(USER1);
        controller.mint(
            _mintAmount,
            bytes32("Fabric"),
            bytes32("FAB"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 1, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            _mintAmount,
            bytes32("Fabric2"),
            bytes32("FAB2"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 2, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER3);
        controller.mint(
            _mintAmount,
            bytes32("Fabric3"),
            bytes32("FAB3"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 3, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER4);
        controller.mint(
            _mintAmount,
            bytes32("Fabric4"),
            bytes32("FAB4"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 4, _mintAmount, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](4);
        uint256[] memory amounts = new uint256[](4);
        contentIds[0] = 1;
        contentIds[1] = 2;
        contentIds[2] = 3;
        contentIds[3] = 4;

        amounts[0] = _mintAmount;
        amounts[1] = _mintAmount;
        amounts[2] = _mintAmount;
        amounts[3] = _mintAmount;

        vm.startPrank(USER5);
        assertEq(asset.isApprovedForAll(USER5, address(controller)), true);
        controller.mint(
            _mintAmount, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), ""
        );
        // check consumed amounts
        assertEq(controller.getAssetContentAmount(5, 1), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 2), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 3), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 4), _mintAmount);
        // //
        assertEq(controller.getAssetContentIndex(5, 1), 0);
        assertEq(controller.getAssetContentIndex(5, 2), 1);
        assertEq(controller.getAssetContentIndex(5, 3), 2);
        assertEq(controller.getAssetContentIndex(5, 4), 3);
        // // check locked amounts
        assertEq(asset.balanceOf(address(controller), 1), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 2), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 3), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 4), _mintAmount);
        assertEq(controller.getContentCount(5), 4);

        contentIds = new uint256[](4);
        amounts = new uint256[](4);
        contentIds[0] = 2; // remove
        contentIds[1] = 1;
        contentIds[2] = 4;
        contentIds[3] = 3;

        amounts[0] = _mintAmount; // remove
        amounts[1] = 100 ether; //3
        amounts[2] = 100 ether; //2
        amounts[3] = 100 ether; //1
        assertEq(controller.getContentLength(5), 4);
        assertEq(controller.getContentLength(5), controller.getContentCount(5));
        controller.reduceContentAmounts(5, contentIds, amounts, bytes(""));
        assertEq(controller.getContentLength(5), 3);
        assertEq(controller.getContentCount(5), 3);
        // check indexes
        assertEq(controller.getAssetContentIndex(5, 2), 3); // 1
        assertEq(controller.getAssetContentIndex(5, 1), 0); // 2
        assertEq(controller.getAssetContentIndex(5, 3), 2); // 3
        assertEq(controller.getAssetContentIndex(5, 4), 1); // 4
        // check amounts
        assertEq(controller.getAssetContentAmount(5, 1), 900 ether);
        assertEq(controller.getAssetContentAmount(5, 2), 0);
        assertEq(controller.getAssetContentAmount(5, 3), 900 ether);
        assertEq(controller.getAssetContentAmount(5, 4), 900 ether);
        // check lock amounts
        assertEq(asset.balanceOf(address(controller), 1), 900 ether);
        assertEq(asset.balanceOf(address(controller), 2), 0);
        assertEq(asset.balanceOf(address(controller), 3), 900 ether);
        assertEq(asset.balanceOf(address(controller), 4), 900 ether);
        vm.stopPrank();
    }

    function test_reduceContentAmounts_remove_two__succeeds_and_updates_removes_zero_Amount_content() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();
        uint256 _mintAmount = 1000 ether;
        vm.startPrank(USER1);
        controller.mint(
            _mintAmount,
            bytes32("Fabric"),
            bytes32("FAB"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 1, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            _mintAmount,
            bytes32("Fabric2"),
            bytes32("FAB2"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 2, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER3);
        controller.mint(
            _mintAmount,
            bytes32("Fabric3"),
            bytes32("FAB3"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 3, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER4);
        controller.mint(
            _mintAmount,
            bytes32("Fabric4"),
            bytes32("FAB4"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 4, _mintAmount, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](4);
        uint256[] memory amounts = new uint256[](4);
        contentIds[0] = 1;
        contentIds[1] = 2;
        contentIds[2] = 3;
        contentIds[3] = 4;

        amounts[0] = _mintAmount;
        amounts[1] = _mintAmount;
        amounts[2] = _mintAmount;
        amounts[3] = _mintAmount;

        vm.startPrank(USER5);
        assertEq(asset.isApprovedForAll(USER5, address(controller)), true);
        controller.mint(
            _mintAmount, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), ""
        );
        // check consumed amounts
        assertEq(controller.getAssetContentAmount(5, 1), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 2), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 3), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 4), _mintAmount);
        //
        assertEq(controller.getAssetContentIndex(5, 1), 0);
        assertEq(controller.getAssetContentIndex(5, 2), 1);
        assertEq(controller.getAssetContentIndex(5, 3), 2);
        assertEq(controller.getAssetContentIndex(5, 4), 3);
        // check locked amounts
        assertEq(asset.balanceOf(address(controller), 1), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 2), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 3), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 4), _mintAmount);
        assertEq(controller.getContentCount(5), 4);

        contentIds = new uint256[](4);
        amounts = new uint256[](4);
        contentIds[0] = 2; // remove
        contentIds[1] = 1;
        contentIds[2] = 4; // remove
        contentIds[3] = 3;

        amounts[0] = _mintAmount; // 2 remove
        amounts[1] = 100 ether; // 1
        amounts[2] = _mintAmount; // 4 remove
        amounts[3] = 100 ether; // 3
        assertEq(controller.getContentLength(5), 4);
        assertEq(controller.getContentLength(5), controller.getContentCount(5));
        controller.reduceContentAmounts(5, contentIds, amounts, bytes(""));
        assertEq(controller.getContentLength(5), 2);
        assertEq(controller.getContentCount(5), 2);
        vm.expectRevert(abi.encodeWithSelector(AssetControllerBase.AssetController__NotAssetContent.selector, 2));
        controller.getAssetContentIndexWithRevert(5, 2);
        vm.expectRevert(abi.encodeWithSelector(AssetControllerBase.AssetController__NotAssetContent.selector, 4));
        controller.getAssetContentIndexWithRevert(5, 4);
        // check indexes
        assertEq(controller.getAssetContentIndex(5, 2), 3); // 1
        assertEq(controller.getAssetContentIndex(5, 4), 2); // 2
        assertEq(controller.getAssetContentIndex(5, 1), 0); // 3
        assertEq(controller.getAssetContentIndex(5, 3), 1); // 4
        // check amounts
        assertEq(controller.getAssetContentAmount(5, 1), 900 ether);
        assertEq(controller.getAssetContentAmount(5, 2), 0);
        assertEq(controller.getAssetContentAmount(5, 3), 900 ether);
        assertEq(controller.getAssetContentAmount(5, 4), 0);
        // check lock amounts
        assertEq(asset.balanceOf(address(controller), 1), 900 ether);
        assertEq(asset.balanceOf(address(controller), 2), 0);
        assertEq(asset.balanceOf(address(controller), 3), 900 ether);
        assertEq(asset.balanceOf(address(controller), 4), 0);
        vm.stopPrank();
    }

    function test_reduceContentAmounts_remove_three__succeeds_and_updates_removes_zero_Amount_content() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();
        uint256 _mintAmount = 1000 ether;
        vm.startPrank(USER1);
        controller.mint(
            _mintAmount,
            bytes32("Fabric"),
            bytes32("FAB"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 1, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            _mintAmount,
            bytes32("Fabric2"),
            bytes32("FAB2"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 2, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER3);
        controller.mint(
            _mintAmount,
            bytes32("Fabric3"),
            bytes32("FAB3"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 3, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER4);
        controller.mint(
            _mintAmount,
            bytes32("Fabric4"),
            bytes32("FAB4"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 4, _mintAmount, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](4);
        uint256[] memory amounts = new uint256[](4);
        contentIds[0] = 1;
        contentIds[1] = 2;
        contentIds[2] = 3;
        contentIds[3] = 4;

        amounts[0] = _mintAmount;
        amounts[1] = _mintAmount;
        amounts[2] = _mintAmount;
        amounts[3] = _mintAmount;

        vm.startPrank(USER5);
        assertEq(asset.isApprovedForAll(USER5, address(controller)), true);
        controller.mint(
            _mintAmount, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), ""
        );
        // check consumed amounts
        assertEq(controller.getAssetContentAmount(5, 1), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 2), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 3), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 4), _mintAmount);
        //
        assertEq(controller.getAssetContentIndex(5, 1), 0);
        assertEq(controller.getAssetContentIndex(5, 2), 1);
        assertEq(controller.getAssetContentIndex(5, 3), 2);
        assertEq(controller.getAssetContentIndex(5, 4), 3);
        // check locked amounts
        assertEq(asset.balanceOf(address(controller), 1), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 2), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 3), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 4), _mintAmount);
        assertEq(controller.getContentCount(5), 4);

        contentIds = new uint256[](4);
        amounts = new uint256[](4);
        contentIds[0] = 2; // remove
        contentIds[1] = 1;
        contentIds[2] = 4; // remove
        contentIds[3] = 3;

        amounts[0] = _mintAmount; // 2 remove
        amounts[1] = 100 ether; // 1
        amounts[2] = _mintAmount; // 4 remove
        amounts[3] = _mintAmount; // 3
        assertEq(controller.getContentLength(5), 4);
        assertEq(controller.getContentCount(5), 4);
        assertEq(controller.getContentLength(5), controller.getContentCount(5));

        assertEq(controller.getAssetContentIndexWithRevert(5, 1), 0);
        assertEq(controller.getAssetContentIndexWithRevert(5, 2), 1);
        assertEq(controller.getAssetContentIndexWithRevert(5, 3), 2);
        assertEq(controller.getAssetContentIndexWithRevert(5, 4), 3);

        controller.reduceContentAmounts(5, contentIds, amounts, bytes(""));
        assertEq(controller.getContentLength(5), 1);
        assertEq(controller.getContentCount(5), 1);
        vm.expectRevert(abi.encodeWithSelector(AssetControllerBase.AssetController__NotAssetContent.selector, 2));
        controller.getAssetContentIndexWithRevert(5, 2);
        vm.expectRevert(abi.encodeWithSelector(AssetControllerBase.AssetController__NotAssetContent.selector, 4));
        controller.getAssetContentIndexWithRevert(5, 4);
        vm.expectRevert(abi.encodeWithSelector(AssetControllerBase.AssetController__NotAssetContent.selector, 3));
        controller.getAssetContentIndexWithRevert(5, 3);
        assertEq(controller.getAssetContentIndexWithRevert(5, 1), 0);
        // check indexes
        assertEq(controller.getAssetContentIndex(5, 2), 3); // 1
        assertEq(controller.getAssetContentIndex(5, 4), 2); // 2
        assertEq(controller.getAssetContentIndex(5, 3), 1); // 4
        assertEq(controller.getAssetContentIndex(5, 1), 0); // 3
        // check amounts
        assertEq(controller.getAssetContentAmount(5, 1), 900 ether);
        assertEq(controller.getAssetContentAmount(5, 2), 0);
        assertEq(controller.getAssetContentAmount(5, 3), 0);
        assertEq(controller.getAssetContentAmount(5, 4), 0);
        // check lock amounts
        assertEq(asset.balanceOf(address(controller), 1), 900 ether);
        assertEq(asset.balanceOf(address(controller), 2), 0);
        assertEq(asset.balanceOf(address(controller), 3), 0);
        assertEq(asset.balanceOf(address(controller), 4), 0);
        vm.stopPrank();
    }

    function test_reduceContentAmounts__should_revert_with__NotAssetContent() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();
        uint256 _mintAmount = 1000 ether;
        vm.startPrank(USER1);
        controller.mint(
            _mintAmount,
            bytes32("Fabric"),
            bytes32("FAB"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 1, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            _mintAmount,
            bytes32("Fabric2"),
            bytes32("FAB2"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 2, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER3);
        controller.mint(
            _mintAmount,
            bytes32("Fabric3"),
            bytes32("FAB3"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 3, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER4);
        controller.mint(
            _mintAmount,
            bytes32("Fabric4"),
            bytes32("FAB4"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 4, _mintAmount, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](4);
        uint256[] memory amounts = new uint256[](4);
        contentIds[0] = 1;
        contentIds[1] = 2;
        contentIds[2] = 3;
        contentIds[3] = 4;

        amounts[0] = _mintAmount;
        amounts[1] = _mintAmount;
        amounts[2] = _mintAmount;
        amounts[3] = _mintAmount;

        vm.startPrank(USER5);
        assertEq(asset.isApprovedForAll(USER5, address(controller)), true);
        controller.mint(
            _mintAmount, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), ""
        );
        contentIds = new uint256[](4);
        amounts = new uint256[](4);
        contentIds[0] = 2; // remove
        contentIds[1] = 1;
        contentIds[2] = 4; // remove
        contentIds[3] = 3;

        amounts[0] = _mintAmount; // 2 remove
        amounts[1] = 100 ether; // 1
        amounts[2] = 100 ether; // 4 remove
        amounts[3] = 100 ether; // 3

        controller.reduceContentAmounts(5, contentIds, amounts, bytes(""));

        contentIds = new uint256[](3);
        amounts = new uint256[](3);
        contentIds[0] = 2; // remove
        contentIds[1] = 1;
        contentIds[2] = 3; // remove

        amounts[0] = _mintAmount; // 2 remove
        amounts[1] = 0; // 1
        amounts[2] = 0; // 4 remove

        vm.expectRevert(abi.encodeWithSelector(AssetControllerBase.AssetController__NotAssetContent.selector, 2));
        controller.reduceContentAmounts(5, contentIds, amounts, bytes(""));
    }

    function test_reduceContentAmounts_multiple_calls__succeeds_and_updates_removes_zero_Amount_content() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();
        uint256 _mintAmount = 1000 ether;
        vm.startPrank(USER1);
        controller.mint(
            _mintAmount,
            bytes32("Fabric"),
            bytes32("FAB"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 1, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            _mintAmount,
            bytes32("Fabric2"),
            bytes32("FAB2"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 2, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER3);
        controller.mint(
            _mintAmount,
            bytes32("Fabric3"),
            bytes32("FAB3"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 3, _mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER4);
        controller.mint(
            _mintAmount,
            bytes32("Fabric4"),
            bytes32("FAB4"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 4, _mintAmount, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](4);
        uint256[] memory amounts = new uint256[](4);
        contentIds[0] = 1;
        contentIds[1] = 2;
        contentIds[2] = 3;
        contentIds[3] = 4;

        amounts[0] = _mintAmount;
        amounts[1] = _mintAmount;
        amounts[2] = _mintAmount;
        amounts[3] = _mintAmount;

        vm.startPrank(USER5);
        assertEq(asset.isApprovedForAll(USER5, address(controller)), true);
        controller.mint(
            _mintAmount, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), ""
        );
        // check consumed amounts
        assertEq(controller.getAssetContentAmount(5, 1), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 2), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 3), _mintAmount);
        assertEq(controller.getAssetContentAmount(5, 4), _mintAmount);
        //
        assertEq(controller.getAssetContentIndex(5, 1), 0);
        assertEq(controller.getAssetContentIndex(5, 2), 1);
        assertEq(controller.getAssetContentIndex(5, 3), 2);
        assertEq(controller.getAssetContentIndex(5, 4), 3);
        // check locked amounts
        assertEq(asset.balanceOf(address(controller), 1), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 2), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 3), _mintAmount);
        assertEq(asset.balanceOf(address(controller), 4), _mintAmount);
        assertEq(controller.getContentCount(5), 4);

        contentIds = new uint256[](4);
        amounts = new uint256[](4);
        contentIds[0] = 2; // remove
        contentIds[1] = 1;
        contentIds[2] = 4;
        contentIds[3] = 3;

        amounts[0] = _mintAmount; // 2 remove
        amounts[1] = 100 ether; // 1
        amounts[2] = 100 ether; // 4
        amounts[3] = 100 ether; // 3
        assertEq(controller.getContentLength(5), 4);
        assertEq(controller.getContentCount(5), 4);
        assertEq(controller.getContentLength(5), controller.getContentCount(5));

        assertEq(controller.getAssetContentIndexWithRevert(5, 1), 0);
        assertEq(controller.getAssetContentIndexWithRevert(5, 2), 1);
        assertEq(controller.getAssetContentIndexWithRevert(5, 3), 2);
        assertEq(controller.getAssetContentIndexWithRevert(5, 4), 3);

        controller.reduceContentAmounts(5, contentIds, amounts, bytes(""));
        assertEq(controller.getContentLength(5), 3);
        assertEq(controller.getContentCount(5), 3);
        assertEq(controller.getAssetContentIndex(5, 2), 3);
        assertEq(controller.getAssetContentIndex(5, 1), 0);
        assertEq(controller.getAssetContentIndex(5, 3), 2);
        assertEq(controller.getAssetContentIndex(5, 4), 1);
        //
        assertEq(controller.getAssetContentAmount(5, 1), 900 ether);
        assertEq(controller.getAssetContentAmount(5, 2), 0);
        assertEq(controller.getAssetContentAmount(5, 3), 900 ether);
        assertEq(controller.getAssetContentAmount(5, 4), 900 ether);

        contentIds = new uint256[](3);
        amounts = new uint256[](3);
        contentIds[0] = 3;
        contentIds[1] = 1; // remove
        contentIds[2] = 4;

        amounts[0] = 100 ether; // 2
        amounts[1] = 900 ether; // 1 remove
        amounts[2] = 100 ether; // 4
        controller.reduceContentAmounts(5, contentIds, amounts, bytes(""));
        assertEq(controller.getContentLength(5), 2);
        assertEq(controller.getContentCount(5), 2);
        assertEq(controller.getAssetContentIndex(5, 2), 3);
        assertEq(controller.getAssetContentIndex(5, 1), 2);
        assertEq(controller.getAssetContentIndex(5, 3), 0);
        assertEq(controller.getAssetContentIndex(5, 4), 1);
        //
        assertEq(controller.getAssetContentAmount(5, 1), 0);
        assertEq(controller.getAssetContentAmount(5, 2), 0);
        assertEq(controller.getAssetContentAmount(5, 3), 800 ether);
        assertEq(controller.getAssetContentAmount(5, 4), 800 ether);

        contentIds = new uint256[](2);
        amounts = new uint256[](2);
        contentIds[0] = 3;
        contentIds[1] = 4; // remove

        amounts[0] = 100 ether; // 2 remove
        amounts[1] = 800 ether; // 1
        controller.reduceContentAmounts(5, contentIds, amounts, bytes(""));
        assertEq(controller.getContentLength(5), 1);
        assertEq(controller.getContentCount(5), 1);
        assertEq(controller.getAssetContentIndex(5, 4), 1);

        assertEq(controller.getAssetContentAmount(5, 1), 0);
        assertEq(controller.getAssetContentAmount(5, 2), 0);
        assertEq(controller.getAssetContentAmount(5, 3), 700 ether);
        assertEq(controller.getAssetContentAmount(5, 4), 0);

        contentIds = new uint256[](1);
        amounts = new uint256[](1);
        contentIds[0] = 3; //
        amounts[0] = 700 ether;
        // 1
        controller.reduceContentAmounts(5, contentIds, amounts, bytes(""));
        assertEq(controller.getContentLength(5), 0);
        assertEq(controller.getContentCount(5), 0);
        assertEq(controller.getAssetContentIndex(5, 3), 0);

        assertEq(controller.getAssetContentAmount(5, 1), 0);
        assertEq(controller.getAssetContentAmount(5, 2), 0);
        assertEq(controller.getAssetContentAmount(5, 3), 0);
        assertEq(controller.getAssetContentAmount(5, 4), 0);
        vm.stopPrank();
    }

    function test_consume_reverts_with_NotAssetOwner() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 200e18;
        amounts[1] = 200e18;

        vm.startPrank(USER3);
        vm.expectEmit(true, true, true, true);
        emit Consume(USER3, 3, contentIds, amounts);
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        vm.stopPrank();

        // add assets to assetid 3
        vm.startPrank(USER2);
        vm.expectRevert(AssetController.AssetController__NotAssetOwner.selector);
        controller.consume(3, contentIds, amounts, "");
        vm.stopPrank();
    }

    function test_consume_reverts_with__ZeroAssetBalance() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 200e18;
        amounts[1] = 200e18;

        vm.startPrank(USER3);
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        controller.transfer(USER1, 3, 1000e18, "");
        vm.expectRevert(AssetController.AssetController__CannotConsumeToZeroAssetBalance.selector);
        controller.consume(3, contentIds, amounts, "");
        vm.stopPrank();
    }

    function test_multiple_consume_with_reordered_content_index_ordering_succeeds() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();
        uint256 mintAmount = 1000 ether;
        vm.startPrank(USER1);
        controller.mint(
            mintAmount,
            bytes32("Fabric"),
            bytes32("FAB"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 1, mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            mintAmount,
            bytes32("Fabric2"),
            bytes32("FAB2"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 2, mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER3);
        controller.mint(
            mintAmount,
            bytes32("Fabric3"),
            bytes32("FAB3"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 3, mintAmount, "");
        vm.stopPrank();

        vm.startPrank(USER4);
        controller.mint(
            mintAmount,
            bytes32("Fabric4"),
            bytes32("FAB4"),
            new uint256[](0),
            new uint256[](0),
            bytes32("external_ref"),
            ""
        );
        controller.transfer(USER5, 4, mintAmount, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 100e18;
        amounts[1] = 100e18;

        vm.startPrank(USER5);
        controller.mint(mintAmount, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        controller.consume(5, contentIds, amounts, "");
        // controller.consume(5, contentIds, amounts, "");
        assertEq(controller.getAssetContentIndex(5, 1), 0);
        assertEq(controller.getAssetContentIndex(5, 2), 1);
        // second consume
        contentIds = new uint256[](3);
        amounts = new uint256[](3);
        // mix content indexes in the array to ensure code assigns correct indexes to previous
        // consumed content
        contentIds[0] = 3;
        contentIds[1] = 1;
        contentIds[2] = 2;
        amounts[0] = 100e18;
        amounts[1] = 100e18;
        amounts[2] = 100e18;
        controller.consume(5, contentIds, amounts, "");
        assertEq(controller.getAssetContentIndex(5, 1), 0);
        assertEq(controller.getAssetContentIndex(5, 2), 1);
        assertEq(controller.getAssetContentIndex(5, 3), 2);
        // consume 3
        contentIds = new uint256[](4);
        amounts = new uint256[](4);
        // mix content indexes in the array to ensure code assigns correct indexes to previous
        // consumed content
        contentIds[0] = 2;
        contentIds[1] = 3;
        contentIds[2] = 4;
        contentIds[3] = 1;
        amounts[0] = 100e18;
        amounts[1] = 100e18;
        amounts[2] = 100e18;
        amounts[3] = 100e18;
        vm.expectEmit(true, true, true, true);
        emit Consume(USER5, 5, contentIds, amounts);
        controller.consume(5, contentIds, amounts, "");
        assertEq(controller.getAssetContentIndex(5, 1), 0);
        assertEq(controller.getAssetContentIndex(5, 2), 1);
        assertEq(controller.getAssetContentIndex(5, 3), 2);
        assertEq(controller.getAssetContentIndex(5, 4), 3);
        vm.stopPrank();
    }

    function test_consume_succeeds() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();

        vm.startPrank(USER1);
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 1, 500e18, "");
        vm.stopPrank();

        vm.startPrank(USER2);
        controller.mint(
            500e18, bytes32("Fabric2"), bytes32("FAB2"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.transfer(USER3, 2, 500e18, "");
        vm.stopPrank();

        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 200e18;
        amounts[1] = 200e18;

        vm.startPrank(USER3);
        vm.expectEmit(true, true, true, true);
        emit Consume(USER3, 3, contentIds, amounts);
        controller.mint(1000e18, bytes32("ITEM1"), bytes32("ITM1"), contentIds, amounts, bytes32("external_ref"), "");
        controller.consume(3, contentIds, amounts, "");
        vm.stopPrank();

        assertEq(asset.balanceOf(address(controller), 1), 400e18);
        assertEq(asset.balanceOf(address(controller), 2), 400e18);
        assertEq(asset.balanceOf(USER3, 1), 100e18);
        assertEq(asset.balanceOf(USER3, 2), 100e18);
        uint256[] memory content = controller.getAssetContent(3);
        assertEq(content[0], 1);
        assertEq(content[1], 2);
        uint256 contentAmount1 = controller.getAssetContentAmount(3, 1);
        uint256 contentAmount2 = controller.getAssetContentAmount(3, 2);
        assertEq(contentAmount1, 400e18);
        assertEq(contentAmount2, 400e18);
    }

    function test_transfer__reverts_with__ZeroAmount() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();
        vm.startPrank(msg.sender);
        vm.expectRevert(AssetController.AssetController__ZeroAmount.selector);
        controller.transfer(USER3, 1, 0, "");
        vm.stopPrank();
    }

    function test_transfer__reverts_with__ZeroAddress() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();
        vm.startPrank(msg.sender);
        vm.expectRevert(AssetController.AssetController__ZeroAddress.selector);
        controller.transfer(address(0), 1, 10e18, "");
        vm.stopPrank();
    }

    function test_transfer__reverts_with__InsufficientBalance() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        vm.expectRevert("ERC1155: insufficient balance for transfer");
        controller.transfer(USER2, 1, 1000e18, "");
        vm.stopPrank();
    }

    function test_transfer__succeeds() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        vm.expectEmit(false, false, false, false);
        emit Transfer(msg.sender, USER2, 1, 100e18);
        controller.transfer(USER2, 1, 100e18, "");
        vm.stopPrank();
        assertEq(asset.balanceOf(USER2, 1), 100e18);
    }

    function test_batchTransferFrom__reverts_with__ZeroAddress() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        vm.stopPrank();
        vm.startPrank(msg.sender);
        vm.expectRevert(AssetController.AssetController__ZeroAddress.selector);
        controller.batchTransferFrom(address(0), new uint256[](2), new uint256[](2), "");
        vm.stopPrank();
    }

    function test_batchTransferFrom__succeeds() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        controller.mint(
            500e18, bytes32("Fabric"), bytes32("FAB"), new uint256[](0), new uint256[](0), bytes32("external_ref"), ""
        );
        uint256[] memory contentIds = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        contentIds[0] = 1;
        contentIds[1] = 2;
        amounts[0] = 200e18;
        amounts[1] = 200e18;
        vm.expectEmit(false, false, false, false);
        emit BatchTransfer(msg.sender, USER2, contentIds, amounts);
        controller.batchTransferFrom(USER2, contentIds, amounts, "");
        vm.stopPrank();
        assertEq(asset.balanceOf(USER2, 1), 200e18);
        assertEq(asset.balanceOf(USER2, 2), 200e18);
        assertEq(asset.balanceOf(msg.sender, 300e18), 0);
        assertEq(asset.balanceOf(msg.sender, 300e18), 0);
    }

    function test_setExternalContentRef_reverts_with_CallerIsNotOwner() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        uint256[] memory contentIds = new uint256[](0);
        uint256[] memory amounts = new uint256[](0);
        controller.mint(500e18, bytes32("Fabric"), bytes32("FAB"), contentIds, amounts, bytes32("external_ref"), "");
        vm.stopPrank();
        vm.startPrank(USER1);
        vm.expectRevert("Ownable: caller is not the owner");
        controller.setAssetExternalContentRef(1, bytes32("external_ref"));
        vm.stopPrank();
    }

    function test_setExternalContentRef_reverts_with_UnknownAsset() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        uint256[] memory contentIds = new uint256[](0);
        uint256[] memory amounts = new uint256[](0);
        controller.mint(500e18, bytes32("Fabric"), bytes32("FAB"), contentIds, amounts, bytes32("external_ref"), "");
        vm.expectRevert(abi.encodeWithSelector(AssetControllerBase.AssetController__UnknownAsset.selector, uint256(2)));
        controller.setAssetExternalContentRef(2, bytes32("external_ref"));
        vm.stopPrank();
    }

    function test_setExternalContentRef_reverts_with_ZeroByes32() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        uint256[] memory contentIds = new uint256[](0);
        uint256[] memory amounts = new uint256[](0);
        controller.mint(500e18, bytes32("Fabric"), bytes32("FAB"), contentIds, amounts, bytes32("external_ref"), "");
        vm.expectRevert(abi.encodeWithSelector(AssetControllerBase.AssetController__ZeroByes32.selector));
        controller.setAssetExternalContentRef(1, bytes32(""));
        vm.stopPrank();
    }

    function test_setExternalContentRef_succeeds() public {
        vm.startPrank(msg.sender);
        asset.transferOwnership(address(controller));
        uint256[] memory contentIds = new uint256[](0);
        uint256[] memory amounts = new uint256[](0);
        controller.mint(500e18, bytes32("Fabric"), bytes32("FAB"), contentIds, amounts, bytes32(""), "");
        controller.setAssetExternalContentRef(1, bytes32("external_ref"));
        assertEq(controller.getAssetExternalContentRef(1), bytes32("external_ref"));
        vm.stopPrank();
    }

    function test_setMaxContentPerTransaction_reverts_with_CallerIsNotOwner() public {
        vm.startPrank(USER3);
        vm.expectRevert("Ownable: caller is not the owner");
        controller.setMaxContentPerTransaction(1);
        vm.stopPrank();
    }

    function test_setMaxContentPerTransaction_succeeds() public {
        vm.startPrank(msg.sender);
        controller.setMaxContentPerTransaction(90);
        assertEq(controller.maxContentPerTransaction(), uint256(90));
        vm.stopPrank();
    }
}
