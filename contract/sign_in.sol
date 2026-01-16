/**
 *Submitted for verification at BscScan.com on 2026-01-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract YUMOController is Ownable, ReentrancyGuard {    
    uint256 constant public startTime = 1768348800;
    uint256 constant public secondsPerDay = 1 days;
    address constant private USDTToken = 0x55d398326f99059fF775485246999027B3197955;
    address private receiveAddr = 0x0508D7234473f2a13312B626ce11b6cbdd2A3DA4;

    struct SignInfo {
        address user;
        uint256 time;
    }
    SignInfo[] public signInfos;
    mapping (address => uint256) public lastSignDay;

    mapping(string => uint256) public projectUsdtMap;

    event Signed(address indexed user, uint256 day);
    event ProjectFunded(string indexed id, address indexed funder, uint256 amount);

    constructor() {

    }

    function setReciver(address _receiveAddr) public onlyOwner {
        receiveAddr = _receiveAddr;
    }

    function sign() external nonReentrant {
        uint256 curDay = (block.timestamp - startTime) / secondsPerDay + 1;
        require(lastSignDay[_msgSender()] == 0 || lastSignDay[_msgSender()] < curDay, "Exists");

        SignInfo memory di = SignInfo({
            user: _msgSender(), 
            time: block.timestamp
        });
        signInfos.push(di);

        lastSignDay[_msgSender()] = curDay;

        emit Signed(_msgSender(), curDay);
    }

    function projectUsdt(string calldata id, uint256 _usdtAmt) external nonReentrant {
        require(bytes(id).length > 0, "idNull");
        require(projectUsdtMap[id] == 0, "ProjectUSDTExists");
        require(_usdtAmt >= 1e18, "USDTAmtTooLow");
        require(IERC20(USDTToken).balanceOf(_msgSender()) >= _usdtAmt, "USDTBalanceNotEnough");

        TransferHelper.safeTransferFrom(USDTToken, _msgSender(), receiveAddr, _usdtAmt);

        projectUsdtMap[id] = _usdtAmt;

        emit ProjectFunded(id, _msgSender(), _usdtAmt);
    }

    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        TransferHelper.safeTransfer(tokenAddress, owner(), tokens);
        return true;
    }
}