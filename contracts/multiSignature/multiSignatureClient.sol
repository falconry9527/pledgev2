// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IMultiSignature{
    function getValidSignature(bytes32 msghash,uint256 lastIndex) external view returns(uint256);
}

contract multiSignatureClient{
    uint256 private constant multiSignaturePositon = uint256(keccak256("org.multiSignature.storage"));
    uint256 private constant defaultIndex = 0;

    // 合约部署的时候，把合约多签合约地址存储在 multiSignaturePositon 位置
    constructor(address multiSignature) public {
        require(multiSignature != address(0),"multiSignatureClient : Multiple signature contract address is zero!");
        saveValue(multiSignaturePositon,uint256(multiSignature));
    }

    function getMultiSignatureAddress()public view returns (address){
        return address(getValue(multiSignaturePositon));
    }

    // 直接存储在 storge 的卡槽（slot）里面
    function saveValue(uint256 position,uint256 value) internal
    {
        assembly {
            sstore(position, value)
        }
    }
    // 从卡槽（slot） 读取数据
    function getValue(uint256 position) internal view returns (uint256 value) {
        assembly {
            value := sload(position)
        }
    }

    // 是否有效请求，必须多签账户的 limitedSignNum 个账户同意
    modifier validCall(){
        checkMultiSignature();
        _;
    }

    function checkMultiSignature() internal view {
        uint256 value;
        assembly {
            value := callvalue()
        }
        // 权限申请：msg.sende-> address(this) 的所有权限
        // 用户对本合约的权限
        bytes32 msgHash = keccak256(abi.encodePacked(msg.sender, address(this)));
        address multiSign = getMultiSignatureAddress();
        uint256 newIndex = IMultiSignature(multiSign).getValidSignature(msgHash,defaultIndex);
        require(newIndex > defaultIndex, "multiSignatureClient : This tx is not aprroved");
    }

}