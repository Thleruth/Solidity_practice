pragma solidity ^0.4.0;

contract owned {
    
    address public owner;
    
    function owned() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    
    // Because onlyOwner is added as modifier, then the requierment will be test before
    // the switch of owner
    function transferOwnership(address _newOwner) onlyOwner public {
        owner = _newOwner;
    }
}

contract MyToken is owned {
    
    // balance for every addresses
    mapping (address => uint256) public balanceOf;
    
    // allowance for every addresses [addressAllowed][rightOwner]
    mapping (address => mapping (address => uint256)) public allowance;
    
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint8 public decimals = 18;
    
    // Constructor
    function Mytoken(uint256 _initialSupply, string _tokenName, string _tokenSymbol) public {
        name = _tokenName;                                 
        symbol = _tokenSymbol;
        totalSupply = _initialSupply * 10 ** uint256(decimals); // using the exponential
        balanceOf[msg.sender] = totalSupply;
    }
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Burn(address indexed from, uint256 value);

    //add a transfer checker
    function _transfer(address _sender, address _receiver, uint256 _valueSent) internal {
        require(_receiver != 0x0);
        // Check if the sender has enough
        require(balanceOf[_sender] >= _valueSent);
        // Check for overflows
        // Save this for an assertion in the future
        require(balanceOf[_sender] + _valueSent > balanceOf[_sender]);
        uint previousBalances = balanceOf[_sender] + balanceOf[_receiver];
        
        // Subtract from the sender
        balanceOf[_sender] -= _valueSent;
        // Add the same to the recipient
        balanceOf[_receiver] += _valueSent;
        
        // Little unit test
        assert(balanceOf[_sender] + balanceOf[_receiver] == previousBalances);
        
        // notify the listenner of the transfer
        Transfer(_sender, _receiver, _valueSent);
    }
    
    // send coins
    function transfer(address _receiver, uint256 _valueSent) public {
        // run transfer function with the check
        _transfer(msg.sender, _receiver, _valueSent);
    }
    
    function transferDelegate (address _sender, address _receiver, uint256 _valueSent) public {
        require(allowance[_sender][msg.sender] <= _valueSent);
        allowance[_sender][msg.sender] -= _valueSent;
        // run the transfer with the test
        _transfer(_sender,_receiver, _valueSent);
    }
    
    // burn coins
    function burn(uint256 _valueBurnt) public {
        require(balanceOf[msg.sender] >= _valueBurnt);
        balanceOf[msg.sender] -= _valueBurnt;
        totalSupply -= _valueBurnt;
        Burn(msg.sender, _valueBurnt);
    }
    
    function approve(address _spender, uint256 _valueAllowed) public {
        allowance[msg.sender][_spender] += _valueAllowed;
    }
    
}
