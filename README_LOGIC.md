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

## PledgePool 流程和逻辑
```
流程 : 参考 framework.png
-------------------createPoolInfo之后的操作 -----------------
向池子里面存款/借款 : 
depositLend :  存款人执行存款操作
depositBorrow : 借款人质押操作

---------------- match（settle方法设置）状态的操作--------------------
存款人:
refundLend : 退还过量存款给存款人
claimLend : 存款人领取 sp_token
借款人:
refundBorrow : 退还给借款人的过量存款
claimBorrow : 借款人接收 sp_token 和贷款资金

----------------UNDO（settle方法设置）--------------------
emergencyLendWithdrawal : 存款人紧急提取贷款
emergencyBorrowWithdrawal : 借款人 紧急借款提取

----------------finish/liquidate（finish/liquidate方法设置） 状态的操作--------------------
withdrawLend : 存款人取回本金和利息
withdrawBorrow : 借款人提取剩余的保证金

----------------管理员--------------------
createPoolInfo : 创建池子
settle : 结算
finish : 完成一个借贷池的操作，包括计算利息、执行交换操作、赎回费用和更新池子状态等步骤。
liquidate : 清算
setPause : 设置合约是否暂停


```

## PledgePool 安全
```
ReentrancyGuard : 防重入攻击，在方法上加上关键词 nonReentrant
SafeTransfer: 安全转账:  如果转账失败会自定回滚 :  safeTransfer
MultiSignatureClient: 多签工具
BscPledgeOracle 
```

