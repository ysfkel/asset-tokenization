// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {UpgradeableBeacon} from "@openzeppelin/proxy/beacon/UpgradeableBeacon.sol";

/**
 * @title PayrollBeacon
 * @author Yusuf
 * @notice inherits UpgradeableBeacon. This is the beacon contract for PayrollProxy
 */
contract PayrollBeacon is UpgradeableBeacon {
    /**
     *
     * @param _implementation Address of depolyed Payroll contract
     */
    constructor(address _implementation) UpgradeableBeacon(_implementation) {}
}
