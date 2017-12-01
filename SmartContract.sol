pragma solidity ^0.4.18;

contract CSIContract_Data {
    
    //Address of the creator of the contract. Set to public for debugging purposes
    address public creator = msg.sender;
    
    
    //This is a counter with the ids of the data that is uploaded
    uint256 private id = 0;
    
    //Struct for the data to be uploaded or purchased
    struct Data
    {
        
        uint256 id;     //id of the data
        string info;    //information of the data (brief description so that consumers know what it is)
        string data;    //The data (it can't be shown to the costumer unless they pay)
        uint256 cost;   //minimum cost to display the data
        bool available; //true when the data is initialized
    }
    
    
    event newDataAvailable(string info, uint256 id, uint256 cost);  //Event executed when new data is uploaded
    event DataPurchased(address recipient, string data);            //Event executed when data is purchased (shows the data)      
    event Error(string details);
    
    uint256[] public ids;   //array with ids
    
    mapping (uint256 => Data) dataUploaded; //Map to obtain the data given an id
    
    //Function to initialize the contract
    function CSIContract_Data(string _info, string _data, uint256 _cost) public {
        
        //Add data to the map
        dataUploaded[id] = Data(id, _info, _data, _cost, true);
        
        //Add id to ids array
        ids.push(id);
        
        //Show message (event)
        newDataAvailable(_info, id, _cost);
        
        //increment id counter
        id++;
    } 
    
    //Function to upload new data to the system
    function UploadNewData(string _info, string _data, uint256 _cost) public {
        
        //New data can only be uploaded by the creator
        if (msg.sender != creator)
        {
            Error("Only the creator can upload new data");
        }
        else
        {
        //Add data to the map
        dataUploaded[id] = Data(id, _info, _data, _cost, true);
        
        //Add id to ids array
        ids.push(id);
        
        //Show message (event)
        newDataAvailable(_info, id, _cost);
        
        //increment id counter
        id++;
        }
    } 
    
    
    //Function to purchase data
    function purchaseData(uint256 _id) payable public returns (string data) {
        
        //Check if ether sent is equal or greater than the minimum cost of the data
        if (msg.value < dataUploaded[_id].cost )
        {
            Error("Minimum cost was not met");
        }
        else
        {
        
        //send ether to owner's address
       creator.transfer(msg.value);
        
        //Shows the data, we should probably research how to do this better (TODO)
        DataPurchased(msg.sender, dataUploaded[_id].data);
        return(dataUploaded[_id].data);
        }
    }
    
    //Function to display the information of the data given an ID
    function getDataInfo(uint256 _id) public constant returns (string info, uint256 cost)
    {
        //Get data
        var data = dataUploaded[_id];
        
        //Exit of data does not exist
        if (!data.available){
            revert();
        }
        
        //Return data
        return(data.info, data.cost);
    }
    
    //Function to kill the contract
    function kill() public {
        //It can only be done by the creator
        if (msg.sender == creator)
        {
            selfdestruct(creator);
        }
        else
        {
            Error("Only the creator can kill the contract");
        }
        
        
    }
    
}
