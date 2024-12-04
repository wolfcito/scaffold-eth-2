// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
	function totalSupply() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function transfer(
		address recipient,
		uint256 amount
	) external returns (bool);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
}

contract BorrowContract {
	IERC20 public token; // ERC-20 token to be borrowed
	address public owner;
	uint256 public collateralRatio; // Collateral ratio (e.g., 150% = 1.5)
	uint256 public interestRate; // Interest rate (percentage)

	mapping(address => uint256) public collateralEther; // Ether collateral deposited by each user
	mapping(address => uint256) public borrowedAmount; // Amount of tokens borrowed by each user

	constructor(
		IERC20 _token,
		uint256 _collateralRatio,
		uint256 _interestRate
	) {
		token = _token;
		owner = msg.sender;
		collateralRatio = _collateralRatio;
		interestRate = _interestRate;
	}

	// Function to deposit Ether as collateral
	function depositCollateral() external payable {
		require(msg.value > 0, "You must deposit Ether as collateral.");
		collateralEther[msg.sender] += msg.value;
	}

	// Function to borrow tokens based on provided collateral
	function borrow(uint256 amount) external {
		uint256 maxBorrowable = (collateralEther[msg.sender] *
			collateralRatio) / 1 ether;
		require(amount <= maxBorrowable, "Insufficient collateral.");
		require(
			token.balanceOf(address(this)) >= amount,
			"Not enough tokens available."
		);

		borrowedAmount[msg.sender] += amount;
		token.transfer(msg.sender, amount);
	}

	// Function to repay tokens and withdraw collateral
	function repay(uint256 amount) external {
		require(
			borrowedAmount[msg.sender] >= amount,
			"Repayment amount exceeds borrowed amount."
		);
		uint256 interest = (amount * interestRate) / 100;

		require(
			token.transferFrom(msg.sender, address(this), amount + interest),
			"Token transfer failed."
		);

		borrowedAmount[msg.sender] -= amount;

		if (borrowedAmount[msg.sender] == 0) {
			uint256 collateral = collateralEther[msg.sender];
			collateralEther[msg.sender] = 0;
			payable(msg.sender).transfer(collateral);
		}
	}

	// Only the owner can withdraw excess tokens
	function withdrawTokens(uint256 amount) external {
		require(msg.sender == owner, "Only the owner can withdraw tokens.");
		token.transfer(owner, amount);
	}

	// Only the owner can withdraw excess Ether
	function withdrawEther(uint256 amount) external {
		require(msg.sender == owner, "Only the owner can withdraw Ether.");
		payable(owner).transfer(amount);
	}
}
