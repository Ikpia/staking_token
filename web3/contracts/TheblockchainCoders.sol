// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract TheBlockchainCoders {
    string public name = "@stakingtokens";
    string public symbol = "ST";
    string public standard = "stakingtoken.v.0.1";

    uint256 public totalSupply;
    uint256 public constant initialSupply = 10000 * (10 ** 18);
    uint256 public userId;

    address public owner;
    address[] public tokenHolders;

    mapping(address => TokenHolderInfo) public tokenHolderInfo;
    mapping(address => uint256) public balance;
    mapping(address => mapping(address => uint256)) public allowance;

    struct TokenHolderInfo {
        uint256 tokenId;
        address from;
        address to;
        uint256 totalToken;
        bool _tokenHolder;
    }

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approve(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    constructor() {
        owner = msg.sender;
        balance[owner] = initialSupply;
        totalSupply = initialSupply;
    }

    function increment() internal {
        userId++;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(balance[msg.sender] > amount, "Insufficient funds");
        require(to == address(0), "recepient cannot be a zero address");
        increment();
        balance[msg.sender] -= amount;
        balance[to] += amount;
        TokenHolderInfo storage _tokenHolderInfo = tokenHolderInfo[to];
        _tokenHolderInfo.from = msg.sender;
        _tokenHolderInfo.to = to;
        _tokenHolderInfo.tokenId = userId;
        _tokenHolderInfo._tokenHolder = true;
        _tokenHolderInfo.totalToken = amount;
        tokenHolders.push(to);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(amount <= balance[from], "Insufficient Funds");
        require(amount <= allowance[from][msg.sender], "Insufficient funds");
        balance[from] -= amount;
        balance[to] += amount;
        allowance[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function getTokenholderInfo(
        address holder
    )
        public
        view
        returns (
            uint256 tokenId,
            address from,
            address to,
            uint256 totalToken,
            bool _tokenHolder
        )
    {
        return (
            tokenHolderInfo[holder].tokenId,
            tokenHolderInfo[holder].from,
            tokenHolderInfo[holder].to,
            tokenHolderInfo[holder].totalToken,
            tokenHolderInfo[holder]._tokenHolder
        );
    }

    function getTokenholders() public view returns (address[] memory) {
        return tokenHolders;
    }
}
