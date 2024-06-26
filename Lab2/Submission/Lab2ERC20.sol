// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./../IERC20.sol";

contract MyERC20 is IERC20 {
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name;
    string public symbol;
    uint8 public decimals;

    address private _owner;
    mapping(address => bool) private _frozenAccounts;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        _owner = msg.sender;
        _mint(msg.sender, 10**30); // 1e30
    }

    function _checkOwner() internal view {
        if (_owner != msg.sender) {
            revert();
        }
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function transfer(address recipient, uint256 amount)
        external
        returns (bool) 
    {
        require(!_frozenAccounts[msg.sender], "Account is frozen");

        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns(bool)
    {
        require(!_frozenAccounts[sender], "Account is frozen");

        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _mint(address to, uint256 amount) internal {
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }

    function freezeAccount(address account) public onlyOwner {
        require(!_frozenAccounts[account], "Account is already frozen");
        _frozenAccounts[account] = true;
    }

    function unfreezeAccount(address account) public onlyOwner {
        require(_frozenAccounts[account], "Account is not frozen");
        _frozenAccounts[account] = false;
    }

    function isAccountFrozen(address account) public view returns (bool) {
        return _frozenAccounts[account];
    }
}
