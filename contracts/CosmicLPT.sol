// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

// REVIEW -> Here you can use the Openzeppelin standard, this approach is actually correct since it's an ERC20 nonetheless, it's just that using pre-baked contracts is more convenient
// and makes it easier to customize your token with battle tested code in a more succinct and error proof way, something like:

// --------------------------------- EXAMPLE ----------------------------------------- //

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// contract CosmicLPT is ERC20 {

//     constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

//  function decimals() public view virtual override returns (uint8) {
//         return 18;
//     }
//     function mint(address _to, uint256 _amount) external returns(bool){
//         _mint(_to, _amount);
//         return true;
//     }

// }

// * You can customize it as you please 
// REFS:
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol
// https://docs.openzeppelin.com/contracts/4.x/erc20

contract CosmicLPT {
    string  public name = "CosmicLPToken";
    string  public symbol = "CLPT";
    uint256 public totalSupply = 2500000000000000000000000; // 1 million tokens
    uint8   public decimals = 18;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}
