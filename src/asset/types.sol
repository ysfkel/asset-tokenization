// SPDX-FileCopyrightText: (c) Copyright 2023 PaperTale Technologies, all rights reserved.
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

struct Document {
    uint256 assetId;
    address account; // account that uploads the document
    uint256 timestamp;
    bytes32 documentId; // storage reference of document
}
