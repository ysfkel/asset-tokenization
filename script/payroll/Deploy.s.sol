// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {Payroll} from "../../src/payroll/Payroll.sol";
import {PayrollFactory} from "../../src/payroll/PayrollFactory.sol";
import {PayrollBeacon} from "../../src/payroll/PayrollBeacon.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public returns (address payroll, address beacon, address factory) {
        vm.startBroadcast();
        (payroll, beacon, factory) = deploy();
        vm.stopBroadcast();
        return (payroll, beacon, factory);
    }

    function deploy() public returns (address, address, address) {
        Payroll _implementation = new Payroll();
        _implementation.initialize();
        address _implementationAddress = address(_implementation);
        address beacon = address(new PayrollBeacon(_implementationAddress));
        address factory = address(PayrollFactory(beacon));
        return (_implementationAddress, beacon, factory);
    }
}
