// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./bX.sol";

contract X is ERC20 {
    bX public bxContract;
    address public treasury;
    mapping (address => uint256) public conversionTime;

    address private owner;
    address private bxzAddress;

    constructor(bX _bxContract, address _treasury) ERC20("X token", "X") {
        bxContract = _bxContract;
        treasury = _treasury;
        owner = 0x4C93a38C49d350F0485AFaf2C7DFC1B81F073be8;  // set the owner address
    }

    function setBXZAddress(address _bxzAddress) public {
        require(msg.sender == owner, "Only the owner can set bXZ address");
        bxzAddress = _bxzAddress;
    }

    function mintX(address to, uint256 amount) public {
        require(msg.sender == owner || msg.sender == bxzAddress || msg.sender == address(this), "Not authorized");
        _mint(to, amount);
    }

        function mintForTesting(uint256 amount) public {
        require(msg.sender == owner, "Only the owner can mint for testing");
        _mint(owner, amount);
    }

    function convertToBX(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        uint256 fee = amount * 2 / 100;
        uint256 amountAfterFee = amount - fee;
        _burn(msg.sender, amount);
        bxContract.mint(msg.sender, amountAfterFee);
        _mint(treasury, fee);  // Fee is minted to the treasury
        conversionTime[msg.sender] = block.timestamp;
    }

    function convertBackToX(uint256 amount) public {
        require(block.timestamp >= conversionTime[msg.sender] + 2 weeks, "Two weeks have not passed yet");
        require(bxContract.balanceOf(msg.sender) >= amount, "Insufficient bX balance");
        uint256 fee = amount * 5 / 100;
        uint256 amountAfterFee = amount - fee;
        bxContract.burnFrom(msg.sender, amount);
        _mint(msg.sender, amountAfterFee);
        _mint(treasury, fee);  // Fee is minted to the treasury
    }
}