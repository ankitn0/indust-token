// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract INDUST is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ERC20Permit, ERC20Votes {
    address public rewardPool;
    uint256 public transferTax = 5; // 5%
    address public paymentReceiver;

    constructor(address _rewardPool)
        ERC20("INDUST", "INDUST")
        ERC20Permit("INDUST")
    {
        rewardPool = _rewardPool;
        paymentReceiver = msg.sender;
        _mint(msg.sender, 1_000_000_000_000 * 10 ** decimals()); // 1T tokens
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setTransferTax(uint256 tax) public onlyOwner {
        require(tax <= 10, "Max tax is 10%");
        transferTax = tax;
    }

    function setPaymentReceiver(address receiver) public onlyOwner {
        paymentReceiver = receiver;
    }

    function pay(address to, uint256 amount) public {
        _transfer(msg.sender, paymentReceiver, amount);
        emit Paid(msg.sender, to, amount);
    }

    event Paid(address from, address to, uint256 amount);

    // OVERRIDES

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function _transfer(address from, address to, uint256 amount)
        internal
        override
    {
        if (transferTax > 0 && from != owner() && to != owner()) {
            uint256 taxAmount = (amount * transferTax) / 100;
            super._transfer(from, rewardPool, taxAmount);
            super._transfer(from, to, amount - taxAmount);
        } else {
            super._transfer(from, to, amount);
        }
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address from, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(from, amount);
    }
}
