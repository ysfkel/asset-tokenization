// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {BeaconProxy} from "@openzeppelin/proxy/beacon/BeaconProxy.sol";

/**
 * @title PayrollProxy
 * @author Yusuf
 * @notice Proxy for Payroll contract
 */
contract PayrollProxy is BeaconProxy {
    /**
     * @param _beacon Address of deployed Payrol beacon contract
     */
    constructor(address _beacon) BeaconProxy(_beacon, "") {}

    /**
     * @notice returns the address of the Payrol implementation contract used by the proxy
     */
    function getImplementation() external view returns (address) {
        return _implementation();
    }

    /**
     * @notice returns the address of the beacon contract
     */
    function getBeacon() external view returns (address) {
        return _beacon();
    }
}
