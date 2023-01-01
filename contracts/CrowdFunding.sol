// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

  /**
   * @title CrowdfundingCampaign
   * @dev ContractDescription
   * @custom:dev-run-script ./scripts/deploy.js
   */
 

// Crowdfunding contract that allows users to pledge funds in the form of a custom ERC20 token
// and receive a refund if the funding goal is not met.
// The contract is also upgradeable.
contract CrowdfundingCampaign {
   using SafeMath for uint256;

    // The contract's ERC20 token
    ERC20 public token;

    // The address of the contract owner
    address public owner;

    // The funding goal for the project
    uint256 public fundingGoal;

    // The amount of funds pledged so far
    uint256 public totalFunds;

    // Whether the funding goal has been met or not
    bool public goalMet;

    // Event that is emitted when the funding goal is met
    event GoalMet();

    // Event that is emitted when the contract is upgraded
    event Upgraded(address newImplementation);

    // The address of the contract's current implementation
    address public implementation;

    // The address of the contract's upgraded implementation
    address public newImplementation;

    // Constructor that initializes the contract with the specified ERC20 token
    // and funding goal, and sets the contract owner to the creator of the contract.
    constructor(ERC20 _token, uint256 _fundingGoal)  {
        token = _token;
        owner = msg.sender;
        fundingGoal = _fundingGoal;
        implementation = address(this);
    }

    // Modifier that restricts access to the contract owner only
    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    // Function that allows the contract owner to upgrade the contract by specifying the address
    // of the new implementation.
    function upgrade(address _newImplementation) public onlyOwner {
        newImplementation = _newImplementation;
    }

    // Function that allows users to pledge funds for the project by transferring the specified
    // amount of the contract's ERC20 token to the contract.
    function pledge(uint256 _amount) public payable {
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        totalFunds = totalFunds.add(_amount);
            if (totalFunds >= fundingGoal) {
            goalMet = true;
            emit GoalMet();
        }
    }

    // Function that allows users to request a refund of their pledged funds if the funding goal
    // has not been met.
    function refund() public {
        require(!goalMet, "Goal has been met");
        uint256 refundAmount = token.balanceOf(msg.sender);
        require(refundAmount > 0, "No funds to refund");
        require(token.transfer(msg.sender, refundAmount), "Transfer failed");
        totalFunds = totalFunds.sub(refundAmount);
    }

    // Function that allows the contract owner to release the funds to the project beneficiary.
    function releaseFunds() public view onlyOwner {
        require(goalMet, "Goal has not been met");
       
    }
}