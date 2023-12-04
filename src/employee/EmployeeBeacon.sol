// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {UpgradeableBeacon} from "@openzeppelin/proxy/beacon/UpgradeableBeacon.sol";

/**
 * @title EmployeeBeacon
 * @author Yusuf
 * @notice inherits UpgradeableBeacon. This is the beacon contract for EmployeeProxy
 */
contract EmployeeBeacon is UpgradeableBeacon {
    /**
     *
     * @param _implementation Address of depolyed Employee contract
     */
    constructor(address _implementation) UpgradeableBeacon(_implementation) {}
}
