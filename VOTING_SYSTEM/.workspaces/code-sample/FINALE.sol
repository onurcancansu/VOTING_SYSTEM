// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract MyGov is ERC20 { 
    // constructor function that creates the MyGov token contract
    constructor(uint256 tokenSupply) ERC20("MyGov", "MGV") {
        // mints the specified amount of tokens to the msg.sender address
        _mint(msg.sender, tokenSupply = 10000000);
    }
    // Variables to track the total amount of ether and MyGov token donations
    uint public totalEtherDonations;
    uint public totalMGVTokenDonations;
    // Mapping to store the donors and their donation amounts
    mapping (address => uint) donors;
    mapping(address => uint ) balances;
    mapping(address => uint ) myGovbalances;
    mapping(address => uint ) public tokenBalances;
    mapping(address => uint ) public etherBalances;
    // mapping to track whether an address has already received a token
    mapping(address => bool) public receivedTokens;
    // a variable that stores the address of the winning proposal
    address payable public winningProposal;

    /**
* function that allows users to donate ether to the contract
*/
    function donateEther() public payable {
        // store the ether balance of the msg.sender in a mapping
        balances[msg.sender] = msg.value;
        // require that the donation is greater than zero
        require(msg.value > 0, "Donation must be greater than zero");
        // require that the contract has sufficient balance to accept the donation
        require(msg.value <= address(this).balance, "Insufficient balance in contract"); 
        // update the total ether donations
        totalEtherDonations += msg.value;
    }

    
    /**
* function that allows users to donate MyGov tokens to the contract
*/
    function donateInMyGovTokens(uint amount) public {
        // store the MyGov token balance of the msg.sender in a mapping
        myGovbalances[msg.sender] = amount;
        // require that the donor has sufficient balance in their account
        require(amount <= myGovbalances[msg.sender], "Insufficient balance in donor's account");
        // update the total MyGov token donations
        totalMGVTokenDonations += amount;
    }

    
    /**
* function that allows the contract to send a specified amount of ether 
* from one account to another
*/
    function sendEther(address from, address payable recipient, uint256 amount) public payable {
        // require that the contract has sufficient balance to send the ether
        require(address(this).balance >= amount, "Insufficient balance");
        // transfer the specified amount of ether to the recipient address
        recipient.transfer(amount);
        // increment the ether balance of the recipient by 1
        etherBalances[recipient] += 1;
    }

    /**
* function that sends a specified number of MyGov tokens from the total supply to a specified address
*/
    function sendMyGovTokens(address from, address recipient, uint amount) public   {
        // require that there are enough tokens left in the total supply
        require(amount > 0, "There are no tokens left in the total supply.");
        // send the specified number of tokens to the recipient address
        tokenBalances[recipient] += amount;
    }

    // Function to check if an address is a member
    function isMember(address payable memberAddr) public view returns (bool) {
        // If the token balance for the given address is greater than or equal to 1,
        // then the address is a member. Otherwise, it is not a member.
        return tokenBalances[memberAddr] >= 1;
    }

    /**
* Struct to represent a project proposal
*/
struct ProjectProposal {
    // unique id of the project proposal
    uint projectId;
    // address of the owner of the proposal
    address owner;
    // IPFS hash of the proposal details
    string ipfsHash;
    // timestamp when voting on the proposal will end
    uint voteDeadline;
    // array of payment amounts for the project
    uint[] paymentAmounts;
    // array of payment schedule for the project
    uint[] paymentSchedule;
    // number of yes votes for the proposal
    uint numYesVotes;
    // number of no votes for the proposal
    uint numNoVotes;
    // flag to indicate if the proposal is funded
    bool funded;
    // flag to indicate if the proposal passed the vote
    bool proposalPassed;
    // flag to indicate if the payment schedule for the project is passed
    bool paymentPassed;
    // flag to indicate if the project is terminated
    bool terminated;
    // Store the addresses of members who have voted or delegated their vote for each project proposal
    address[] votedMembers;
    address[] delegatedMembers;
}

    // Store the addresses of members who have voted or delegated their vote for each project proposal
    mapping(uint => address) public delegatedVotes;
    mapping(uint => address) public votedMembers;

    /**
* Struct to represent a payment for a funded project
*/
    struct ProjectPayment {
        // unique id of the payment
        uint paymentId;
        // id of the project to which the payment belongs
        uint projectId;
        // amount of the payment
        uint paymentAmount;
        // date of the payment
        uint paymentDate;
        // number of yes votes for the payment
        uint numYesVotesPay;
        // number of no votes for the payment
        uint numNoVotesPay;
    }

            // Array of member structs
    Member[] public members;
    // Store the balance of MyGov tokens for each member
    //mapping(address => uint) public memberBalances;
    // Struct to represent a member
    /**
* Struct to represent a member of the organization
*/
    struct Member {
        // flag to indicate if the address is a member
        bool isMember;
        // address of the member
        address payable memberAddr;
    }

    /**
    * function that returns the total number of members in the organization
    */
    function memberCount() public view returns (uint) {
        // variable to keep track of the number of members
        uint count = 0;
        // loop through the members array
        for (uint i = 0; i < members.length; i++) {
            // check if the current member is a member
            if (members[i].isMember) {
                // increment the count if the current member is a member
                count++;
            }
        }
        // return the final count
        return count;
    }

    // Mapping from project ID to voting details
    mapping(uint => Voting) public voting;

    /**
* Struct to hold voting details
*/
    struct Voting {
        // mapping of addresses that voted for the proposal
        mapping(address => bool) votesFor;
        // mapping of addresses that voted against the proposal
        mapping(address => bool) votesAgainst;
        // number of votes for the proposal
        uint votesForCount;
        // number of votes against the proposal
        uint votesAgainstCount;
        // flag to indicate if the address has already voted
        bool hasVoted;
        // address of the delegate of the voter
        address delegate;
    }


    // Mapping from project ID to proposal
    mapping(uint => ProjectProposal) public proposals;
    // Total number of proposals
    //uint public numProposals;

    // Mapping from payment ID to payment
    mapping(uint => ProjectPayment) public payments;

    // Array of funded project IDs
    uint[] public fundedProjects;

    // Mapping from project ID to total ether received
    mapping(uint => uint) public etherReceived;

    // Counter for project IDs
    uint public projectCounter;

    // Counter for payment IDs
    uint public paymentCounter;

    // Submit a project proposal
    function submitProjectProposal(string memory ipfsHash, uint voteDeadline, uint[] memory paymentAmounts, uint[] memory paymentSchedule) public payable  returns (uint projectId) {
        // Assign a unique project ID
        projectId = projectCounter;
        projectCounter++;
            // Require the caller to have at least 1 MyGov token
        require(tokenBalances[msg.sender] >= 1, "Must have at least 1 MyGov token to submit a project proposal");
        // Require the caller to have enough ether to pay the submission fee
        require(msg.value >= 0.1 ether, "Insufficient ether to pay submission fee");
        // Deduct 5 MyGov tokens from the caller's balance
        tokenBalances[msg.sender] -= 5;
        // Store the proposal
        proposals[projectId] = ProjectProposal(projectId, msg.sender, ipfsHash, voteDeadline, paymentAmounts, paymentSchedule, 0, 0, false, false, false, false, new address[](0), new address[](0));
    }

    // Vote for a project proposal
    function voteForProjectProposal(uint projectId, bool choice) public {
        // Retrieve the project proposal
        ProjectProposal storage proposal = proposals[projectId];
        // Require the caller to have at least 1 MyGov token
        require(tokenBalances[msg.sender] >= 1, "Must have at least 1 MyGov token to submit a project proposal");
        // Check that the project ID is valid and the vote deadline has not passed
        require(proposals[projectId].projectId == projectId, "Invalid project ID");
        require(block.timestamp <= proposals[projectId].voteDeadline, "Vote deadline has passed");
        // Require the caller to have not already voted or delegated their vote for this project proposal
        require(proposal.votedMembers.length == 0 && proposal.delegatedMembers.length == 0, "Cannot vote or delegate vote after already voting or delegating vote");
        // Check that the member has not already voted or delegated their vote
        require(msg.sender.balance > 0, "Member has already voted or delegated their vote");
        //Check that the member has balance more than 0
        require(tokenBalances[msg.sender] > 0, "Cannot reduce MyGov balance to zero before voting deadlines");
        // Store the vote
        if (choice) {
            proposals[projectId].numYesVotes++;
        } else {
            proposals[projectId].numNoVotes++;
        }
        // Add the caller to the list of voted members
        proposal.votedMembers.push(msg.sender);
        
    }

    // Function to delegate vote to another member
  function delegateVoteTo(address memberaddr, uint projectId) public {
    // Retrieve the project proposal
    ProjectProposal storage proposal = proposals[projectId];
    // Require the caller to be a member
    require(tokenBalances[msg.sender] >= 1, "Must be a member to delegate vote");
    // Require the voting period to be open
    // Check that the project ID is valid and the vote deadline has not passed
    require(proposals[projectId].projectId == projectId, "Invalid project ID");
    require(block.timestamp <= proposals[projectId].voteDeadline, "Vote deadline has passed");

    // Require the caller to have not already voted or delegated their vote for this project proposal
    require(proposal.votedMembers.length == 0 && proposal.delegatedMembers.length == 0, "Cannot vote or delegate vote after already voting or delegating vote");
    // Require the specified member to be a member
    require(tokenBalances[memberaddr] >= 1, "Specified member is not a member");
    // Delegate the vote to the specified member
    delegatedVotes[projectId] = memberaddr;
    // Add the caller to the list of delegated members
    proposal.delegatedMembers.push(msg.sender);
  }

  // Reserve funding for a project
    function reserveProjectGrant(uint projectId) public {
        // Check that the project ID is valid and at least 1/10 of the members have voted "yes"
        require(proposals[projectId].projectId == projectId, "Invalid project ID");
        require(proposals[projectId].numYesVotes >= memberCount() / 10, "Not enough votes to fund project");

        // Check that there is sufficient ether in the contract to fund the project
        require(address(this).balance >= proposals[projectId].paymentAmounts[0], "Insufficient ether in contract");

        // Mark the project as funded
        proposals[projectId].funded = true;

        // Store the project in the list of funded projects
        fundedProjects.push(projectId);

        // Create the first payment for the project
        uint paymentId = paymentCounter;
        paymentCounter++;
        payments[paymentId] = ProjectPayment(paymentId, projectId, proposals[projectId].paymentAmounts[0], proposals[projectId].paymentSchedule[0], 0, 0);
    }
    // Vote for a project payment
    function voteForProjectPayment(uint paymentId, bool choice) public {
        // Check that the payment ID is valid
        require(payments[paymentId].paymentId == paymentId, "Invalid payment ID");

        // Check that the member has not already voted or delegated their vote
        require(msg.sender.balance > 0, "Member has already voted or delegated their vote");

        // Store the vote
        if (choice) {
            payments[paymentId].numYesVotesPay++;
        } else {
            payments[paymentId].numNoVotesPay++;
        }
    }

    
    // Withdraw a payment for a funded project
    function withdrawProjectPayment(uint paymentId) public {
        // Check that the payment ID is valid and the payment date has passed
        require(payments[paymentId].paymentId == paymentId, "Invalid payment ID");
        require(block.timestamp >= payments[paymentId].paymentDate, "Payment date has not passed");

        // Check that at least 1/100 of the members have voted "yes"
        require(payments[paymentId].numYesVotesPay >= memberCount() / 100, "Not enough votes to release payment");

        // Check that the project is still funded
        require(proposals[payments[paymentId].projectId].funded, "Project is no longer funded");

        // Check that the project owner is the one trying to withdraw the payment
        require(proposals[payments[paymentId].projectId].owner == msg.sender, "Only the project owner can withdraw payments");

        // Check that the payment amount is not greater than the scheduled amount
        require(payments[paymentId].paymentAmount <= proposals[payments[paymentId].projectId].paymentAmounts[payments[paymentId].paymentId], "Payment amount exceeds scheduled amount");

        // Transfer the payment amount to the project owner
        //msg.sender.transfer(payments[paymentId].paymentAmount);
        // Transfer the payment amount to the project owner
        payable(msg.sender).transfer(payments[paymentId].paymentAmount);
        // Update the total ether received by the project
        etherReceived[payments[paymentId].projectId] += payments[paymentId].paymentAmount;

        // Create the next payment for the project if there is one
        if (payments[paymentId].paymentId < proposals[payments[paymentId].projectId].paymentAmounts.length - 1) {
            paymentId = paymentCounter;
            paymentCounter++;
            payments[paymentId] = ProjectPayment(paymentId, payments[paymentId].projectId, proposals[payments[paymentId].projectId].paymentAmounts[payments[paymentId].paymentId + 1], proposals[payments[paymentId].projectId].paymentSchedule[payments[paymentId].paymentId + 1], 0, 0);
        } else {
            // Mark the project as not funded if there are no more payments
            proposals[payments[paymentId].projectId].funded = false;
        }
    }

    // Check if a project is funded
    function getIsProjectFunded(uint projectId) public view returns (bool funded) {
        return proposals[projectId].funded;
    }

    // Get the next payment for a funded project
    function getProjectNextPayment(uint projectId) public view returns (int nextPayment) {
        if (!proposals[projectId].funded) {
            return -1;
        }

        for (uint i = 0; i < proposals[projectId].paymentAmounts.length; i++) {
            if (block.timestamp < proposals[projectId].paymentSchedule[i]) {
                return int(proposals[projectId].paymentSchedule[i]);
            }
        }

        return -1;
    }

    // Get the owner of a project
    function getProjectOwner(uint projectId) public view returns (address projectOwner) {
        return proposals[projectId].owner;
    }

    
    // Get the details of a project
    function getProjectInfo(uint projectId) public view returns (string memory ipfsHash, uint voteDeadline, uint[] memory paymentAmounts, uint[] memory paymentSchedule) {
        // Retrieve the project proposal
        ProjectProposal storage proposal = proposals[projectId];
        return (proposals[projectId].ipfsHash, proposals[projectId].voteDeadline, proposals[projectId].paymentAmounts, proposals[projectId].paymentSchedule);
    }

    // Get the number of project proposals
    function getNoOfProjectProposals() public view returns (uint numProposals) {
        return projectCounter;
    }

    // Get the number of funded projects
    function getNoOfFundedProjects() public view returns (uint numFunded) {
        return fundedProjects.length;
    }

    // Get the total ether received by a project
    function getEtherReceivedByProject(uint projectId) public view returns (uint amount) {
        return etherReceived[projectId];
    }

    // structure to represent a survey
    struct Survey {
        uint surveyid;
        string ipfshash;      // IPFS hash of the survey content
        uint surveydeadline;       // deadline for taking the survey
        uint[] numChoices;     // number of choices in the survey
        uint[] atMostChoice;   // maximum number of choices that a member can select
        mapping (uint => bool) choices; // mapping to track the choices made by the members
        bool active;
    }
    Survey survey;
    
    // mapping to store the surveys
    mapping (uint => Survey) public surveys;
    
    // counter to generate unique survey IDs
    uint public surveyCounter;

/*
    // function to create a new survey
    function submitSurvey(string memory ipfshash, uint surveydeadline,  uint[] memory numChoices, uint[] memory atMostChoice) public payable  returns (uint surveyid) {
	// Assign a unique project ID
        surveyid = surveyCounter;
        // increment the survey counter to get a unique ID for the survey
        surveyCounter++;
        
// Require the caller to have at least 1 MyGov token
        require(tokenBalances[msg.sender] >= 1, "Must have at least 1 MyGov token to submit a project proposal");
        // calculate the deadline for the survey (one week from now)
        uint surveydeadline = block.timestamp + 7 days;
        // Require the caller to have enough ether to pay the submission fee
        require(msg.value >= 0.04 ether, "Insufficient ether to pay submission fee");
        // Deduct 5 MyGov tokens from the caller's balance
        tokenBalances[msg.sender] -= 2;
        surveys[surveyid] = new  Survey(surveyid, msg.sender, ipfshash, surveydeadline, numChoices, atMostChoice, false, false);
    }


    // function to allow members to take a survey
        // function to allow members to take a survey
    function takeSurvey(uint surveyid, uint[] memory choices) public {
        // retrieve the survey from the mapping
        Survey storage survey = surveys[surveyid];

        // check if the survey exists
        require(surveyid <= surveyCounter, "Survey does not exist");

        // check if the survey deadline has not passed
        require(now <= survey.deadline, "Survey deadline has passed");

        // check if the number of choices made is within the allowed range
        require(choices.length <= survey.atMostChoice, "Number of choices exceeds the allowed limit");

        // mark the chosen options as selected
        for (uint i = 0; i < choices.length; i++) {
            survey.choices[choices[i]] = true;
        }
    }
        // function to retrieve the survey results
    function getSurveyResults(uint surveyid) public view returns(uint numtaken, uint [] memory results) {
        // retrieve the survey from the mapping
        Survey storage survey = surveys[surveyid];

        // check if the survey exists
        require(surveyid <= surveyCounter, "Survey does not exist");

        // initialize variables to store the number of surveys taken and the results
        numtaken = survey.numTaken;
        for (uint i = 0; i < survey.numChoices; i++) {
            if (survey.choices[i]) {
                results.push(i);
            }
        }
    }

    // function to retrieve the survey information
    function getSurveyInfo(uint surveyid) public view returns(string memory ipfshash, uint surveydeadline, uint numchoices, uint atmostchoice) {
        // retrieve the survey from the mapping
        Survey storage survey = surveys[surveyid];

        // check if the survey exists
        require(surveyid <= surveyCounter, "Survey does not exist");

        // retrieve the survey information
        ipfshash = survey.ipfshash;
        surveydeadline = survey.deadline;
        numchoices = survey.numChoices;
        atmostchoice = survey.atMostChoice;
    }

    // function to retrieve the survey owner
    function getSurveyOwner(uint surveyid) public view returns(address surveyowner) {
        // retrieve the survey from the mapping
        Survey storage survey = surveys[surveyid];

        // check if the survey exists
        require(surveyid <= surveyCounter, "Survey does not exist");

        // retrieve the survey owner
        surveyowner = survey.owner;
    }

    // function to retrieve the number of surveys
    function getNoOfSurveys() public view returns(uint numsurveys) {
        numsurveys = surveyCounter;
    }*/


}