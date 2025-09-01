# pledgeV2
pledge V2 contract

# 逻辑整理
## 各个合约的作用
```
PledgePool: 借贷主协议

```

## PledgePool 安全
```
ReentrancyGuard : 防重入攻击，在方法上加上关键词 nonReentrant
SafeTransfer：安全转账： 如果转账失败会自定回滚 ： safeTransfer
MultiSignatureClient: 多签工具
```

## multiSignatureClient 权限多签
```
// bytes32 （请求地址-> 调用的合约地址）： 所有方法的调用权限
 mapping(bytes32=>signatureInfo[]) public signatureMap;

 

```