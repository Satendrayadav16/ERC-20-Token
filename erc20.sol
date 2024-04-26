// SPDX-License-Identifier: MIT

//pragma solidity >= 0.8.0;
pragma solidity >=0.8.2 <0.9.0;

/**
 *@dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */

 library SafeMath {

      /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:- Addition cannot overflow.
     */

     function add (uint256 x, uint256 y) internal pure returns( uint256) {
         uint256 z = x + y;
         require (z >= x, "Safemath: addition overflow");
         return z;
     }
     /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:- Subtraction cannot overflow.
     */
     function sub(uint256 x, uint256 y) internal pure returns (uint256) {
        return sub(x, y, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */

     function sub(uint256 x, uint256 y, string memory errorMessage) internal pure returns (uint256) {
        require(y <= x, errorMessage);
        uint256 z = x - y;
        return z;
     }
    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:- Multiplication cannot overflow.
     */
     function mul(uint256 x, uint256 y) internal pure returns(uint) {
         if (x == 0) {
            return 0;
        }
        uint256 z = x * y;
        require(z / x == y, "SafeMath: multiplication overflow");
        return z;
    }
    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:- The divisor cannot be zero.
     */
    function div(uint256 x, uint256 y) internal pure returns(uint256) {
        return div(x, y, "SafeMath: division by zero");
    }

    function div(uint256 x, uint256 y, string memory errorMessage) internal pure returns (uint256) {
        require(y > 0, errorMessage);
        uint256 z = x / y;
        return z;
    }
 }

abstract contract ERC20Token {

    function name() virtual public view returns (string memory);
    function symbol() virtual public view returns (string memory);
    function decimals() virtual public view returns (uint8);
    function totalSupply() virtual public view returns (uint256);
    function balanceOf(address _owner) virtual public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) virtual public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool success);
    function approve(address _spender, uint256 _value) virtual public returns (bool success);
    function allowance(address _owner, address _spender) virtual public view returns (uint256 remaining);
    

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event burn(address indexed _from, uint256 _value);
    event mint(address indexed _from, uint256 _value);
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address _to) public {
        require(msg.sender == owner);
        newOwner = _to;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract NepToken is ERC20Token, Owned {

    string public _symbol;
    string public _name;
    uint8 public _decimal;
    uint public _totalSupply;
    

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor () {
        _symbol = "NepT";
        _name = "NepToken";
        _decimal = 18;
        _totalSupply = 0;
        
    }

    /**
    *@dev sets the name of the token
    */

    function name() public override view returns (string memory) {
        return _name;
    }

    /**
    *@dev sets the symbol of the token
    */

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
    *@dev sets the assigned decimal after the value
    */
    function decimals() public override view returns (uint8) {
        return _decimal;
    }

     /**
    *@dev sets the total supply of the token
    *returns the total supply of token in existence
    */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
    *@dev returns the amount of token owned by the account
    */
    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances[_owner];
    }

    /**
    *@dev moves amount of token from the sender to receipent account
    *amount is then deducted from sender account after transfer is confirmed
    */

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        require(balances[_from] >= _value);
        balances[_from] -= _value; // balances[_from] = balances[_from] - _value
        balances[_to] += _value;    //balances[_to] = balances[_to] + _value
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    *@dev sends amount of token to receipent account from sender account.
    *returns value indicating if operation is suceeded.
    */

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        return transferFrom(msg.sender, _to, _value);
    }

    /**
    *@dev sets amount as allowance of sender over callers token.
    *returns value as indicaiton of successful operation.
    */

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    *@dev returns remaining number of token that sender will be allowed to sent on behalf of owner.
    * value zero by default
    *value changes when `approve` or `transferFrom` function are called.
    */

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
    *@dev generates amount token in owner account.
    * adds to the `totalSupply` inncreasing the token amount.
    * requirement:- cannot be zero address
    */

    function _mintToken(uint256 _value)  public  returns (bool success) {
        require(msg.sender == owner, "admin only has access");
        _totalSupply += _value;
        balances[owner] += _value;
        return true;
    }

    /**
    *@dev destroy amount of token fron owner account
    *burned amount reduces value from `totalSupply`.
    *requirements:- 1. owner account cannot be zero address
                *   2. owner account value cannot be zero and have atleast some amount of token.
    */

    function _burnToken( uint256 _value) public returns(bool success) {
        require(msg.sender == owner, "admin only has access");
        _totalSupply -= _value;
        balances [owner] -= _value;
        emit burn(msg.sender, _value);
        return true;
    }

}
