// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./bX.sol";
import "./X.sol";

contract bXZ is ERC20 {
    bX public bxContract;
    X public xContract;
    address public treasury;
    mapping (address => uint256) public conversionTime;

    address private owner;

    constructor(bX _bxContract, X _xContract, address _treasury) ERC20("bXZ token", "bXZ") {
        bxContract = _bxContract;
        xContract = _xContract;
        treasury = _treasury;
        owner = 0x4C93a38C49d350F0485AFaf2C7DFC1B81F073be8;  // set the owner address
    }

    function convertToBXZ(uint256 amount) public {
        require(bxContract.balanceOf(msg.sender) >= amount, "Insufficient bX balance");
        uint256 fee = amount * 2 / 100;
        uint256 amountAfterFee = amount - fee;
        bxContract.burnFrom(msg.sender, amount);
        _mint(msg.sender, amountAfterFee);
        _mint(treasury, fee);  // Fee is minted to the treasury
        conversionTime[msg.sender] = block.timestamp;
    }

    function convertBackToX(uint256 amount) public {
        require(block.timestamp >= conversionTime[msg.sender] + 4 weeks, "Four weeks have not passed yet");
        require(balanceOf(msg.sender) >= amount, "Insufficient bXZ balance");
        uint256 fee = amount * 5 / 100;
        uint256 amountAfterFee = amount - fee;
        _burn(msg.sender, amount);
        xContract.mintX(msg.sender, amountAfterFee);  
        xContract.transfer(treasury, fee);
    }
    
    function distributeBX(address[] memory stakers, uint256 amount) public {
        require(msg.sender == owner, "Only the owner can distribute tokens");
        for (uint i = 0; i < stakers.length; i++) {
            bxContract.mint(stakers[i], amount);
        }
    }

    function distributeX(address[] memory stakers, uint256 amount) public {
        require(msg.sender == owner, "Only the owner can distribute tokens");
        for (uint i = 0; i < stakers.length; i++) {
            xContract.mintX(stakers[i], amount);
        }
    }
}
