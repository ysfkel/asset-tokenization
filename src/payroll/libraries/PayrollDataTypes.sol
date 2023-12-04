// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/**
 * @title PayrollDataTypes
 * @author Yusuf
 * @notice Library contract for Data types used by Payroll
 */
library PayrollDataTypes {
    // Payrol status
    enum Status {
        None,
        Active,
        Closed
    }

    // Payroll data
    struct PayrollData {
        Status status;
        uint256 publishDate;
        uint256 startDate;
        uint256 endDate;
        uint256 revision;
        bytes32 name;
        bytes32 payrollType;
        bytes32 id;
        bytes32 dataReference;
    }
}
