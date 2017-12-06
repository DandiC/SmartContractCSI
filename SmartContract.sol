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
        mapping (address => bool) purchasedBy; //array of addresses that have purchased the data
    }
    
    
    event newDataAvailable(string info, uint256 id, uint256 cost);  //Event executed when new data is uploaded
    event DataPurchased(address recipient, string data);            //Event executed when data is purchased (shows the data)      
    event Error(string details);
    
    uint256[] ids;   //array with ids
    
    mapping (uint256 => Data) dataUploaded; //Map to obtain the data given an id
    
    //Function to initialize the contract
    function CSIContract_Data(string _info, string _data, uint256 _cost) public {
        
        //Add data to the map
        UploadNewData(_info, _data,  _cost);
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
        
        dataUploaded[id].purchasedBy[creator] = true;
        
        //Add id to ids array
        ids.push(id);
        
        //Show message (event)
        newDataAvailable(_info, id, _cost);
        
        //increment id counter
        id++;
        }
    } 
    
    
    //Function to purchase data
    function purchaseData(uint256 _id) payable public {
        
        var returnedData = dataUploaded[_id];
        
        if (returnedData.available)
        {
            //Convert from wei to ether
            var etherSent = msg.value/1000000000000000000;
            
            //Check if ether sent is equal or greater than the minimum cost of the data
            if (etherSent < returnedData.cost )
            {
                Error("Minimum cost was not met");
            }
            else
            {
            
            dataUploaded[_id].purchasedBy[msg.sender] = true;
            
            //send ether to owner's address
           creator.transfer(msg.value);
            
            //Shows the data, we should probably research how to do this better (TODO)
            DataPurchased(msg.sender, returnedData.data);
            }
        
        }else
        {
            Error("No data was found with the given id");
        }
        
    }
    
    //Function to display the information of the data given an ID
    function getDataInfo(uint256 providedID) public constant returns (uint256 dataID, string info, uint256 cost, string data)
    {
        //Get data
        var d = dataUploaded[providedID];
        
        //Exit of data does not exist
        if (!d.available){
            revert();
        }
        
        var actualData = "Data not available until a purchase is made.";
        
        if (d.purchasedBy[msg.sender])
        {
            actualData = d.data;
        }
        
        //Return data
        return(d.id, d.info, d.cost, actualData);
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
