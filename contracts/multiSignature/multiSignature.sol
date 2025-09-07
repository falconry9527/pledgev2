// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./multiSignatureClient.sol" ;

library whiteListAddress{
    // add whiteList
    function addWhiteListAddress(address[] storage whiteList,address temp) internal{
        if (!isEligibleAddress(whiteList,temp)){
            whiteList.push(temp);
        }
    }
    function removeWhiteListAddress(address[] storage whiteList,address temp)internal returns (bool) {
        uint256 len = whiteList.length;
        uint256 i=0;
        for (;i<len;i++){
            if (whiteList[i] == temp)
                break;
        }
        if (i<len){
            if (i!=len-1) {
                whiteList[i] = whiteList[len-1];
            }
            whiteList.pop();
            return true;
        }
        return false;
    }

    function isEligibleAddress(address[] memory whiteList,address temp) internal pure returns (bool){
        uint256 len = whiteList.length;
        for (uint256 i=0;i<len;i++){
            if (whiteList[i] == temp)
                return true;
        }
        return false;
    }
}


contract multiSignature  is multiSignatureClient {
    uint256 private constant defaultIndex = 0;
    using whiteListAddress for address[];
    // 多签成员
    address[] public signatureOwners;
    uint256 public threshold;
    // 申请的多签信息
    struct signatureInfo {
        // 申请用户的地址
        address applicant;
        // 多签成员
        address[] signatures;
    }
    // 权限（请求地址-> 调用的合约地址）
    mapping(bytes32=>signatureInfo[]) public signatureMap;

   // indexed 关键字用于事件（Event） 的参数声明，它是一个非常重要的功能，主要用于优化链上数据的检索和过滤
   // 存储在日志的 topics 中，可以被高效地过滤和搜索，消耗更多的gass，最多定义3个
    event TransferOwner(address indexed sender,address indexed oldOwner,address indexed newOwner);
    event CreateApplication(address indexed from,address indexed to,bytes32 indexed msgHash);
    event SignApplication(address indexed from,bytes32 indexed msgHash,uint256 index);
    event RevokeApplication(address indexed from,bytes32 indexed msgHash,uint256 index);

    //==========================  设置和修改签名管理人员地址 =========================
    // 初始化管理员 owners 和 最低签名用户数
    //  multiSignatureClient(address(this))  : 显式调用父合约 multiSignatureClient 的构造函数，并将 _multiSignature 参数传递给它
    constructor(address[] memory owners,uint256 limitedSignNum) multiSignatureClient(address(this)) public {
        require(owners.length>=limitedSignNum,"Multiple Signature : Signature threshold is greater than owners' length!");
        signatureOwners = owners;
        threshold = limitedSignNum;
    }

    // 修改多签成员
    function transferOwner(uint256 index,address newOwner) public onlyOwner validCall{
        require(index<signatureOwners.length,"Multiple Signature : Owner index is overflow!");
        emit TransferOwner(msg.sender,signatureOwners[index],newOwner);
        signatureOwners[index] = newOwner;
    }

    // 重写 onlyOwner ： 是不是管理员之一： signatureOwners
    modifier onlyOwner{
        require(signatureOwners.isEligibleAddress(msg.sender),"Multiple Signature : caller is not in the ownerList!");
        _;
    }
    
    //==========================  用户申请权限（签名）/管理员签名权限 相关 =========================
    // 创建申请，请求签证
    // signatureInfo[] 是数组的意思是： 允许多次申请，只要有一次通过就可以了
    function createApplication(address to) external returns(uint256) {
        bytes32 msghash = getApplicationHash(msg.sender,to);
        uint256 index = signatureMap[msghash].length;
        // 创建一个起始长度为0的可变数组
        // 创建 一个固定长度为5的数组：  new address[5]()
        signatureMap[msghash].push(signatureInfo(msg.sender,new address[](0)));
        emit CreateApplication(msg.sender,to,msghash);
        return index;
    }

    // 管理员签名（某个申请）
    // onlyOwner: 是管理员之一
    // defaultIndex
    function signApplication(bytes32 msghash) external onlyOwner validIndex(msghash,defaultIndex){
        emit SignApplication(msg.sender,msghash,defaultIndex);
        // 把管理员的地址加到签名列表
        signatureMap[msghash][defaultIndex].signatures.addWhiteListAddress(msg.sender);
    }

    // 管理员移除签名（某个申请）
    function revokeSignApplication(bytes32 msghash) external onlyOwner validIndex(msghash,defaultIndex){
        emit RevokeApplication(msg.sender,msghash,defaultIndex);
        signatureMap[msghash][defaultIndex].signatures.removeWhiteListAddress(msg.sender);
    }
   
    // 查询有没有通过的签名
    function getValidSignature(bytes32 msghash,uint256 lastIndex) external view returns(uint256){
        signatureInfo[] storage info = signatureMap[msghash];
        for (uint256 i=lastIndex;i<info.length;i++){
            if(info[i].signatures.length >= threshold){
                return i+1;
            }
        }
       return 0; 
    }

    function getApplicationInfo(bytes32 msghash,uint256 index) validIndex(msghash,index) public view returns (address,address[]memory) {
        signatureInfo memory info = signatureMap[msghash][index];
        return (info.applicant,info.signatures);
    }

    function getApplicationCount(bytes32 msghash) public view returns (uint256) {
        return signatureMap[msghash].length;
    }

    function getApplicationHash(address from,address to) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(from, to));
    }

    // 请求的有效性检查，防止数组角标越界
    modifier validIndex(bytes32 msghash,uint256 index){
        // 同意管理员数目，要小于总的
        require(index<signatureMap[msghash].length,"Multiple Signature : Message index is overflow!");
        _;
    }
}