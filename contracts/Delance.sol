// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Delance is ReentrancyGuard {
    address public employer;
    address public freelancer;
    uint256 public deadline;
    uint public price;

    struct Request {
        string title;
        uint256 amount;
        bool locked; // true = pending, false = approved
        bool paid;
    }

    Request[] public requests;

    event RequestCreated(uint indexed index, string title, uint256 amount);
    event RequestApproved(uint indexed index, uint256 amount);
    event FundsReceived(address indexed from, uint amount);
    event FreelancerUpdated(address indexed newFreelancer);
    event DeadlineUpdated(uint256 newDeadline);

    constructor(address _freelancer) payable {
        require(msg.value > 0, "Must fund the contract");
        freelancer = _freelancer;
        employer = msg.sender;
        deadline = block.timestamp + 30 days;
        price = msg.value;
    }

    modifier onlyEmployer() {
        require(msg.sender == employer, "Only employer can call this");
        _;
    }

    modifier onlyFreelancer() {
        require(msg.sender == freelancer, "Only freelancer can call this");
        _;
    }

    receive() external payable {
        price += msg.value;
        emit FundsReceived(msg.sender, msg.value);
    }

    function setFreelancer(address _freelancer) public onlyEmployer {
        freelancer = _freelancer;
        emit FreelancerUpdated(_freelancer);
    }

    function setDeadline(uint _deadline) public onlyEmployer {
        deadline = _deadline;
        emit DeadlineUpdated(_deadline);
    }

    // Step 1: Freelancer requests partial payment
    function createRequest(string memory _title, uint256 _amount) public onlyFreelancer {
        require(_amount <= address(this).balance, "Amount exceeds contract balance");

        requests.push(Request({
            title: _title,
            amount: _amount,
            locked: true,
            paid: false
        }));

        emit RequestCreated(requests.length - 1, _title, _amount);
    }

    // Step 2: Employer approves request and releases payment
    function approveRequest(uint index) public onlyEmployer nonReentrant {
        require(index < requests.length, "Invalid request index");

        Request storage req = requests[index];
        require(req.locked == true, "Request already approved");
        require(req.paid == false, "Already paid");
        require(req.amount <= address(this).balance, "Insufficient contract balance");

        req.locked = false;
        req.paid = true;

        payable(freelancer).transfer(req.amount);
        emit RequestApproved(index, req.amount);
    }

    function getAllRequests() public view returns (Request[] memory) {
        return requests;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
