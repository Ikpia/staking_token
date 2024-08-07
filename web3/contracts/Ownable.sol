// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./Context.sol";

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransfered(
        address indexed newOwner,
        address indexed previousOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier OnlyOwner() {
        require(_msgSender() == _owner, "Sender is not the owner");
        _;
    }

    function renounceOwnership() public virtual OnlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual OnlyOwner {
        require(newOwner != address(0), "Cannot be zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual OnlyOwner {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransfered(_owner, oldOwner);
    }
}
