// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract crowdFunding {
    mapping(address => uint) public contributors;

    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContibutors;

    struct Request {
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint => Request) public requests;

    uint public numRequests;

    constructor(uint _target, uint _deadline) {
        manager = msg.sender;
        target = _target;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100 wei;
    }

    function sendEth() public payable {
        require(block.timestamp < deadline, "Deadline has passed");
        require(
            msg.value > minimumContribution,
            "Minimum contributions is not met"
        );

        if (contributors[msg.sender] == 0) {
            noOfContibutors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function refund() public {
        require(
            contributors[msg.sender] > 0,
            "You cannot ask refund,bcoz u didn't funded yet."
        );
        require(
            block.timestamp > deadline && raisedAmount < target,
            "Refund is not given to u"
        );
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] == 0;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "You cannot access this");
        _;
    }

    function createRequests(
        string memory _description,
        address payable _recepient,
        uint _value
    ) public onlyManager {
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recepient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender] > 0, "You must be a contributer ");
        Request storage thisRequest = requests[_requestNo];
        require(
            thisRequest.voters[msg.sender] == false,
            "You have already voted"
        );
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint _requests) public onlyManager {
        require(raisedAmount >= target);
        Request storage thisRequest = requests[_requests];
        require(
            thisRequest.completed == false,
            "This request has been completed"
        );
        require(
            thisRequest.noOfVoters > noOfContibutors / 2,
            "Majprity does not support"
        );
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;
        raisedAmount -= thisRequest.value;
    }
}
