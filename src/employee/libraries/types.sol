// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

enum AgeVerification {
    Unverified,
    UnderAged,
    Approved
}

enum Gender {
    Male,
    Female
}

// Payroll data
struct EmployeeType {
    address account;
    bytes32 employeeId;
    uint256 dateOfBirth;
    Gender gender;
    bool active;
    AgeVerification ageVerification;
}
