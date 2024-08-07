// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IERC20 {
    event Transfer(
        address indexed sender,
        uint256 amount,
        address indexed receiver
    );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function balanceof(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address spender,
        address receiver,
        uint256 amount
    ) external returns (bool);
}
