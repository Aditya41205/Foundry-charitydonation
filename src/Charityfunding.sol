// SPDX-License-Identifier: MIT

/**
 * @title Charity funding smart-contract
 * @author Aditya
 * @dev   Collects funds from user and owner can donate to charity using their address
 */
pragma solidity ^0.8.28;

contract CharityDonation{



//Error
error Charity__CHARITYNOTOPEN();
error Charity__NOTENOUGHFUNDS();

//Enums

enum State{
 OPEN,CLOSED
}

 


  //Variables
uint256 public ENTRANCE_VALUE;
State private s_state;
address[] public donators;
address public owner;
uint256 private immutable i_timefordonation;


//events
event DONATOR(uint256 amount,address sender);

//struct
struct Donor{
    uint256 amount;
    string  name;
    string feedback;
}

mapping (address=>Donor) public donorinfo;

//Constructor
constructor( ){
  ENTRANCE_VALUE=0.01 ether;
  s_state= State.OPEN;
  owner=msg.sender;
  i_timefordonation=block.timestamp+ 7 days;

}



  //functions
  function fund( string  memory _name,string memory _feedback) public payable{
   require(i_timefordonation>block.timestamp,"Donating time is over");
    if(s_state!=State.OPEN){
        revert Charity__CHARITYNOTOPEN();
    }
    require(msg.value>=ENTRANCE_VALUE,"Give enough eth");

 
    Donor memory donor= donorinfo[msg.sender];
    donor.amount+=msg.value;
       donorinfo[msg.sender]=Donor({amount:donor.amount,name:_name,feedback:_feedback});
       donators.push(msg.sender);
       emit DONATOR(donor.amount, msg.sender);
  }


  function sendtocharity(address _charityaddress) public payable{
    
    s_state = State.CLOSED;
    if(s_state!= State.CLOSED){
        revert(); 
    }
    require(owner==msg.sender,"ONLY OWNER CAN WITHDRAW");
    (bool sucess,)=payable(_charityaddress).call{value:address (this).balance}("");
    if(sucess!=true){
        revert Charity__NOTENOUGHFUNDS();
    }
  }

   
}