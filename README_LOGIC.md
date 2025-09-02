# pledgeV2
pledge V2 contract

# 逻辑整理
## 各个合约的作用
```
PledgePool : 借贷主协议
multiSignatureClient : 权限多签
DebtToken : 铸造借贷双方的币
BscPledgeOracle : charlink 获取币子价格
```

## multiSignatureClient 权限多签
```
// bytes32 （请求地址-> 调用的合约地址）:  所有方法的调用权限
// signatureInfo[] 允许多次申请，只要有其中一个申请允许就可以了
 mapping(bytes32=>signatureInfo[]) public signatureMap;
 validIndex :    请求的有效性检查，防止数组角标越界
 validCall(checkMultiSignature) : 请求数组中，是否有1个是过签的
```

## PledgePool 逻辑
```
depositLend :  存款人执行存款操作
refundLend : 退还过量存款给存款人
```


## PledgePool 安全
```
ReentrancyGuard : 防重入攻击，在方法上加上关键词 nonReentrant
SafeTransfer: 安全转账:  如果转账失败会自定回滚 :  safeTransfer
MultiSignatureClient: 多签工具
BscPledgeOracle 
```

