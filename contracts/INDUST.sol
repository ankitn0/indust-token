// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract INDUST is ERC20, ERC20Burnable, ERC20Pausable, Ownable {
    uint256 public taxPercentage = 2; // 2% transfer tax
    address public rewardPool;
    uint256 private constant INITIAL_SUPPLY = 1_000_000_000_000 * 10 ** 18;

    event Payment(address indexed from, address indexed to, uint256 amount, string message);

    constructor(address _rewardPool) ERC20("INDUST", "INDUST") {
        _mint(msg.sender, INITIAL_SUPPLY);
        rewardPool = _rewardPool;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setTax(uint256 _taxPercentage) public onlyOwner {
        require(_taxPercentage <= 10, "Tax too high");
        taxPercentage = _taxPercentage;
    }

    function setRewardPool(address _rewardPool) public onlyOwner {
        rewardPool = _rewardPool;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function pay(address to, uint256 amount, string memory message) public {
        _transferWithTax(msg.sender, to, amount);
        emit Payment(msg.sender, to, amount, message);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        _transferWithTax(from, to, amount);
    }

    function _transferWithTax(address from, address to, uint256 amount) internal {
        require(!paused(), "Token is paused");

        uint256 tax = (amount * taxPercentage) / 100;
        uint256 amountAfterTax = amount - tax;

        super._transfer(from, rewardPool, tax);
        super._transfer(from, to, amountAfterTax);
    }
}

