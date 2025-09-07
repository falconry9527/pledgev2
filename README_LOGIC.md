# pledgeV2

## 各个合约的作用
```
PledgePool : 借贷主协议
multiSignatureClient : 权限多签
DebtToken : 铸造借贷双方的币
BscPledgeOracle : charlink 获取币价格
```

## PledgePool 安全
```
ReentrancyGuard : 防重入攻击，在方法上加上关键词 nonReentrant
SafeTransfer: 安全转账:  如果转账失败会自定回滚 :  safeTransfer
MultiSignatureClient: 多签工具
BscPledgeOracle 
```

## multiSignatureClient权限多签
```
// bytes32 （请求地址-> 调用的合约地址）:  所有方法的调用权限
// signatureInfo[] 允许多次申请，只要有其中一个申请允许就可以了
 mapping(bytes32=>signatureInfo[]) public signatureMap;
 validIndex :    请求的有效性检查，防止数组角标越界
 validCall(checkMultiSignature) : 请求数组中，是否有1个是过签的
```

## PledgePool流程和逻辑
```
流程 : 参考 framework.png
----------------createPoolInfo之后的操作
向池子里面存款/借款 : 
depositLend :  存款人执行存款操作 getPayableAmount:存入存款并获取金额      
操作数据: lendInfo.stakeAmount, pool.lendSupply 
depositBorrow : 借款人质押操作 getPayableAmount:存入质押代币并获取金额    
操作数据: borrowInfo.stakeAmount,pool.borrowSupply 

---------------- settle方法 --
settle : 启动一个池子，按比例存入存款和借出贷款（启动的时候，多的存款将退还）
操作数据:
data.settleAmountLend = actualValue;
data.settleAmountBorrow = pool.borrowSupply;

---------------- match状态的操作 --
存款人:
refundLend : 退还过量存款给存款人 
claimLend : 存款人领取 sp_token
借款人:
refundBorrow : 退还给借款人的过量存款
claimBorrow : 借款人接收 jp_token 和 贷款资金 

refundLend 多了计算份额的步骤 (refundBorrow一样的)
计算份额: 用户按照比例退款（一个人存入池子存入了200万(pool.lendSupply)，
但是，实际借出了100万(data.settleAmountLend)，那么多存入的100万，就按照比例退给每个用户）

---------------- UNDO状态的操作--
emergencyLendWithdrawal : 存款人紧急提取贷款
emergencyBorrowWithdrawal : 借款人紧急借款提取
这两个方法和 refundLend/refundBorrow 基本一致，分开主要是更省gas(没有计算份额部分)

---------------- finish方法 --
finish: 完成一个借贷池的操作，包括计算利息、执行交换操作、赎回费用和更新池子状态等步骤。
操作数据:
data.finishAmountLend
data.finishAmountBorrow 

---------------- liquidate方法 --
liquidate : 清算
操作数据:
data.liquidationAmounLend 
data.liquidationAmounBorrow

---------------- finish/liquidate 状态的操作 --
withdrawLend : 存款人取回本金和利息 : 销毁 sp_token ，按照份额退款
withdrawBorrow : 借款人提取剩余的保证金 : 销毁 jp_token ，按照份额退款

```


## PledgePool 管理员方法
```

createPoolInfo : 创建池子
settle : 结算
finish : 完成一个借贷池的操作，包括计算利息、执行交换操作、赎回费用和更新池子状态等步骤。
liquidate : 清算
checkoutLiquidate : 是否到达清算阀值
setPause : 设置合约是否暂停

settle: 结算:启动一个池子，按比例存入存款和借出贷款（启动的时候，多的存款将退还）
checkoutLiquidate :是否到达清算阀值: 不断调用，如果到达清算阀值，就会调用清算逻辑 liquidate
liquidate:  清算:到达清算阀值的时候，由管理员调用
finish:  借贷时间到期后，由管理员调用 
```

## indexed
```
indexed 关键字用于事件（Event） 的参数声明，它是一个非常重要的功能，主要用于优化链上数据的检索和过滤
存储在日志的 topics 中，可以被高效地过滤和搜索，消耗更多的gass，最多定义3个
```