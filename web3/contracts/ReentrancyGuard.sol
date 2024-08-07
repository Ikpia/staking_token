// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

abstract contract ReentrancyGuard {
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private status;

    constructor() {
        status = NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(status == NOT_ENTERED, "the function has already entered");
        status = ENTERED;
        _;
        status = NOT_ENTERED;
    }
}
