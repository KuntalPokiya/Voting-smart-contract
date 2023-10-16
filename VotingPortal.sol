//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract VotingPortal{

   address electionCommission;
   address public winner;

   struct Voter{
    string name;
    uint age;
    uint voterID;
    string gender;
    uint voteToCandidateID;
    address voterAddress;
   }

    struct Candidate{
        string name;
        string party;
        uint age;
        string gender;
        uint candidateID;
        address candidateAddress;
        uint votes;
    }

    uint nextVoterID=1;
    uint nextCandidateID=1;
    uint startTime;
    uint endTime;
    bool stopVoting;

    mapping(uint=>Voter) voterDetails;  //Details of Voters
    mapping(uint=>Candidate) candidateDetails;  //Details of Candidates

    constructor(){
        electionCommission=msg.sender;  //Jisne Contract deploy kiya hain woh Election Commision hain
    }

    modifier isVotingOver(){
        require(block.timestamp>endTime || stopVoting==true,"Voting is in progress");
        _;
    }

    modifier onlyCommission(){
        require(electionCommission==msg.sender,"You are not from Election Commision");
        _;
    }

    function candidateRegister(
        string calldata _name,
        string calldata _party,
        uint _age,
        string calldata _gender
    )
    external{
        require(msg.sender!=electionCommission,"You are Election Commission");
        require(candidateVerification(msg.sender)==true,"Candidate has already been registered");
        require(_age>=18,"You are below age,Ja Bournvita pee");
        require(nextCandidateID<3,"Candidate registration has been full");
        candidateDetails[nextCandidateID]=Candidate(_name,_party,_age,_gender,nextCandidateID,msg.sender,0);
        nextCandidateID++;
    }


    function candidateVerification(address _person) internal view returns(bool) {
        for(uint i=1;i<nextCandidateID;i++)
        {
            if(candidateDetails[i].candidateAddress==_person)
            {
                return false; //require statement error throw kar dega
            }
        }
        return true;
    }

    function candidateList() public view returns (Candidate[] memory){
       Candidate[] memory array = new Candidate[](nextCandidateID-1);
       for(uint i=1;i<nextCandidateID;i++){
        array[i-1]=candidateDetails[i];
       }
       return array;
    }

    function voterRegister(string calldata _name,uint _age,string calldata _gender)
    external{
        require(voterVerification(msg.sender)==true,"Voter has already been registered");
        require(_age>=18,"Voter is underage");
        voterDetails[nextVoterID]=Voter(_name,_age,nextVoterID,_gender,0,msg.sender);
        nextVoterID++;
    }

    function voterVerification(address _person) internal view returns(bool){
        for(uint i=1;i<nextVoterID;i++)
        {
            if(voterDetails[i].voterAddress==_person)
            {
                return false; //Voter already registered hain
            }
        }
        return true;
    }

    function voterList() public view returns(Voter[] memory) {
        Voter[] memory array= new Voter[](nextVoterID-1);
        for(uint i=1;i<nextVoterID;i++)
        {
          array[i-1]=voterDetails[i];
        }
        return array;
    }

    function vote(uint _voterID,uint _candidateID)
    external{
       require(voterDetails[_voterID].voteToCandidateID==0,"Voter has already voted");
       require(voterDetails[_voterID].voterAddress==msg.sender,"You are a Thug Voter");
       require(startTime!=0,"Voting has not started yet");
       require(nextCandidateID==3,"candidates have not been registered yet");
       require( _candidateID>0 &&  _candidateID<3,"Invalid Candidate ID");
       voterDetails[_voterID].voteToCandidateID=_candidateID;
       candidateDetails[_candidateID].votes++;
    }


    function voteTime(uint _startTime,uint _endTime) external onlyCommission(){
        startTime=block.timestamp+_startTime;
        endTime=startTime+_endTime;
    }


    function votingStatus() public view returns (string memory)
    { if(startTime==0)
       { return "Voting has not started yet";}
    else if ((startTime!=0 && endTime>block.timestamp) && stopVoting==false)
       {return "Voting is in progress";}
    else
       {return "Voting period is over";}
    }

    function result() external onlyCommission()
    {
        require (nextCandidateID>1,"No candidates have been registered");
        uint maximumVotes = 0;
        address currentWinner;
        for (uint i = 1; i < nextCandidateID; i++)
        {
          if (candidateDetails[i].votes > maximumVotes) 
          {
            maximumVotes=candidateDetails[i].votes;
            currentWinner=candidateDetails[i].candidateAddress;
          }
          winner = currentWinner;
        }
    }
    function emergency() public onlyCommission()
     {
       stopVoting=true;
     }

    
}