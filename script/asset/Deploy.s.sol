// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {Asset} from "../../src/asset/Asset.sol";
import {AssetProxy} from "../../src/asset/AssetProxy.sol";
import {AssetController} from "../../src/asset/AssetController.sol";
import {AssetControllerProxy} from "../../src/asset/AssetControllerProxy.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public returns (address assetProxy, address controllerProxy) {
        vm.startBroadcast();
        (assetProxy, controllerProxy) = deploy();
        vm.stopBroadcast();
        return (assetProxy, controllerProxy);
    }

    function deploy() public returns (address, address) {
        /// Deploy Asset
        string memory tokenUrl = vm.envString("ASSET_TOKEN_URL");
        uint256 _maxContentPerTransaction = vm.envUint("MAX_CONTENT_PER_TRANSACTION");
        require(_maxContentPerTransaction > 0, "MAX_CONTENT_PER_TRANSACTION env CANNOT BE 0");
        address assetImplementation = address(new Asset());
        address assetProxy =
            address(new AssetProxy(address(assetImplementation), abi.encodeCall(Asset.initialize, tokenUrl)));
        Asset asset = Asset(assetProxy);
        /// Deploy AssetController
        bytes memory data = abi.encodeCall(AssetController.initialize, (assetProxy, _maxContentPerTransaction));
        address assetControllerImplentation = address(new AssetController());
        address controllerProxy = address(new AssetControllerProxy(assetControllerImplentation, data));
        asset.transferOwnership(address(controllerProxy));

        return (assetProxy, controllerProxy);
    }
}
