# pledgeV2
pledge V2 contract

# 逻辑整理

## PledgePool 安全
```
ReentrancyGuard : 防重入攻击，在方法上加上关键词 nonReentrant
SafeTransfer：安全转账： 如果转账失败会自定回滚 ： safeTransfer
MultiSignatureClient: 多签工具
```

## PledgePool 主要方法
```

```