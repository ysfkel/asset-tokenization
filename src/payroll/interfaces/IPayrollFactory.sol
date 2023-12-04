// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/**
 * @title PayrollFactory
 * @author Yusuf
 * @notice specification for Payrol factory
 */
interface IPayrollFactory {
    /**
     * @notice This function should only be called by owner of the factory contract (paper tail). deploys payroll proxy and transfers ownership to payrollOwner
     * @param owner address of the owner
     * @param admin address of administrator
     * @return payrollAddress the address of the deployed payrol proxy
     */
    function createPayroll(address owner, address admin) external returns (address payrollAddress);

    /**
     * @notice sets address of the beacon contract for the proxy
     * @param newPayrollBeaconAddress beacon contract address
     */
    function setBeacon(address newPayrollBeaconAddress) external;

    /**
     * @notice returns list of payroll proxy address  for the specified address
     * @param payrollOwner address of payrolls owner
     */
    function getPayrollList(address payrollOwner) external view returns (address[] memory);
}
