pragma solidity <0.7.0;
contract FundraisingFactory{
    address[] public deployedFundraising;
    function createFundraising(uint minimum)public
    {
      address newfundraising = address( new Fundraising(minimum, msg.sender));
      deployedFundraising.push(newfundraising);
    }
    function getDeployedFundraising()public view returns(address[] memory){
        return deployedFundraising;
    }
    
}

contract Fundraising{
    struct Request{
        string desciption;
        uint value;
        address payable recipient;
        bool complete;
        //track voting
        uint approvalCount;
        //view approvers donated
        mapping(address=>bool) approvers;
    }
    Request[] public requests;
    
  address public manager;
  uint public minimumContribution;
  // track all people
  uint public approversCount;
  
  //list of personal contributed
  //address[] public approvers;
  mapping(address=>bool)public approvers;
 
 
  modifier OnlyManager(){
      require(msg.sender == manager);
      _;
  }
  
  constructor(uint minimum ,address creator)public{
      manager = creator;
      //the money lowest contributed
      minimumContribution = minimum;
  }
  function Contribute() public payable{
      require(msg.value > minimumContribution);
      
      // add person run this function on approvers array
     // approvers.push(msg.sender);
     approvers[msg.sender] = true;
     approversCount ++;
  }
  
  function CreateRequest(string memory _desciption,uint _vale,address payable _recipient)
  public OnlyManager{
   Request memory newRequest = Request({
     desciption : _desciption,
     value : _vale,
     recipient : _recipient,
     complete: false,
     approvalCount:0
   });  
   requests.push(newRequest);
  }
  function approveRequest(uint index) public{
      Request storage indexRequest = requests[index];
      
      require(approvers[msg.sender]);
      //check if person contributed and  if don't get out
      require(!indexRequest.approvers[msg.sender]);
      
      //add people into mapping approvers
      indexRequest.approvers[msg.sender]=true;
      
      //Increase the number of people who agreed
      indexRequest.approvalCount ++;
  }
   function finalizeRequset(uint index) public OnlyManager{
        Request storage indexRequest = requests[index];
        require(indexRequest.approvalCount>(approversCount / 2));
        require(!indexRequest.complete);   
        indexRequest.recipient.transfer(indexRequest.value * 1 ether);
        indexRequest.complete = true;
   }
  
  
}