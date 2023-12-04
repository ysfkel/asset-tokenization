// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {PayrollDataTypes as P} from "../libraries/PayrollDataTypes.sol";
/**
 * @title Payroll
 * @author Yusuf
 * @notice specification for Payrol funtionality
 */

interface IPayroll {
    /**
     * @notice adds new invoice and closes the invoice
     * @param startDate start date of invoice
     * @param endDate end date of invoice
     * @param revision revision of the payroll
     * @param name payroll name
     * @param payrollType payrollType
     * @param id identifier of the invoice - decentralized storage identifier of the invoice
     * @param dataReference payrol json data reference
     */
    function addPayrollAndClosePayroll(
        uint256 startDate,
        uint256 endDate,
        uint256 revision,
        bytes32 name,
        bytes32 payrollType,
        bytes32 id,
        bytes32 dataReference
    ) external;

    /**
     * @notice adds new invoice
     * @param startDate start date of invoice
     * @param endDate end date of invoice
     * @param revision revision of the payroll
     * @param name payroll name
     * @param payrollType payrollType
     * @param id identifier of the invoice - decentralized storage identifier of the invoice
     * @param dataReference payrol json data idenfier
     */
    function addPayroll(
        uint256 startDate,
        uint256 endDate,
        uint256 revision,
        bytes32 name,
        bytes32 payrollType,
        bytes32 id,
        bytes32 dataReference
    ) external;

    /**
     * @notice adds dataref to existing payroll
     * @param id payroll id
     * @param dataReference payroll data reference
     */
    function addDatareference(bytes32 id, bytes32 dataReference) external;

    /**
     * @notice Adds data reference to existing payroll and closes the payroll
     * @param id payrol id
     * @param dataReference payrol data reference
     */
    function addDataReferenceAndClosePayroll(bytes32 id, bytes32 dataReference) external;

    /**
     * @notice closes an active payroll by setting its status to closed
     * @param id id of the payrol to close
     */
    function closePayroll(bytes32 id) external;

    /**
     * @notice grants admin role to account
     * @param account to be granted admin role
     */
    function grantAdminRole(address account) external;

    /**
     * @notice revokes admin role from account
     * @param account to be revoked
     */
    function revokeAdminRole(address account) external;

    /**
     * @notice grants owner role to account
     * @param account to be granted admin role
     */
    function grantOwnerRole(address account) external;

    /**
     * @notice revokes owner role from account
     * @param account to be revoked
     */
    function revokeOwnerRole(address account) external;

    /**
     * @notice grants read role to account
     * @param account to be granted read role
     */
    function grantReadRole(address account) external;

    /**
     * @notice revokes read role from account
     * @param account to be revoked
     */
    function revokeReadRole(address account) external;

    /**
     * @notice returns the invoice data
     * @param id identifier of the invoice
     */
    function getPayroll(bytes32 id) external view returns (P.PayrollData memory);

    /**
     * @notice returns the list of payroll ids
     */
    function getPayrollIds() external view returns (bytes32[] memory);

    /**
     * @notice returns the list of payroll Data Identifiers
     */
    function getPayrollDataReferences() external view returns (bytes32[] memory);
}
