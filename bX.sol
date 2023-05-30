// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract bX is ERC20 {
    address public admin;
    address public stakingContract;

    constructor(address _admin) ERC20("bX token", "bX") {
        admin = _admin;
    }

    function setStakingContract(address _stakingContract) external {
        require(msg.sender == admin, "Only the admin can set staking contract");
        stakingContract = _stakingContract;
    }

    function mint(address account, uint256 amount) external {
        require(msg.sender == admin || msg.sender == stakingContract, "Only the admin or staking contract can mint");
        _mint(account, amount);
    }

    function burnFrom(address account, uint256 amount) external {
        require(msg.sender == admin || msg.sender == stakingContract, "Only the admin or staking contract can burn");
        _burn(account, amount);
    }
}
