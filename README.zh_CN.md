# Authing - aws-s3-demo
<div align=center>
  <img width="250" src="https://files.authing.co/authing-console/authing-logo-new-20210924.svg" />
</div>

<div align="center">
    <a href="https://forum.authing.cn/" target="_blank"><img src="https://img.shields.io/badge/chat-forum-blue" /></a>
    <a href="https://opensource.org/licenses/MIT" target="_blank"><img src="https://img.shields.io/badge/License-MIT-success" alt="License"></a>
</div>

**简体中文** | [English](./README.md)

## 简介
Authing 集成 AWS 服务 DEMO

## 参考
- [Authing 身份认证云](https://authing.cn)
- [Demo 在线地址](https://sample.authing.cn/aws-demo/)

## 安装

```sh
yarn install
```

## 使用

```sh
node index.js
```

## 使用 Authing 集成 AWS 服务

Authing 是一个开发者友好、拓展性极高的身份认证云服务，每月有超过 100 万次用户被 Authing 认证和授权。本次分享将介绍如何企业常见的认证授权场景，可以满足中国本地用户对于 Cognito User Pool 的需求，并且提供本地化的服务。同时 Authing 本文将讲解 Authing 如何与 AWS Cognito Identity Pool 集成，并提供一个使用 S3 资源的 Demo。

### Cognito Identity Pool

Cognito User Pool 负责认证。终端用户可以通过 user pool 完成注册登录流程。

Cognito Identity Pool 负责授权（访问控制），将使用 AWS 资源的权利授权给终端用户。

Amazon Web Services(AWS) 虽然作为市场份额全球第一的云计算厂商，其产品也不是完美无缺的，Cognito （AWS 的身份认证解决方案）及其附带的中文文档就是一个反面教材，其难用程度令人发指。当然，除了不易用之外，还有访问速度缓慢，不适用于中国市场等问题存在。

而国产的 Authing 可以解决使用 Cognito 的诸多问题，使用 Authing User Pool， 可以替代 Cognito User Pool，构建起国内用户与 AWS 资源之间的桥梁。

在创建 AWS Identity Pool 时，可以配置自定义 Authentication providers，这里我们将 Developer provider name 设置为 `<authing-userpool-id>.authing.cn`  格式：

![](http://lcjim-img.oss-cn-beijing.aliyuncs.com/2019-12-18-181525.jpg)

![](http://lcjim-img.oss-cn-beijing.aliyuncs.com/2019-12-18-181549.jpg)

整个流程中一共有三方参与：终端用户、Authing 、AWS，具体过程如下：
- 终端用户使用 Authing 用户池完成认证
- Authing 开发者在服务端调用 AWS 的 GetOpenIdTokenForDeveloperIdentity 接口，获得 IdentityId 和 Token。
- 终端用户调用 GetCredentialsForIdentity 使用 token 换取访问 AWS 资源所需的 credentials。

GetOpenIdTokenForDeveloperIdentity 需要以下参数：
- IdentityPoolId：你的 AWS Identity Pool ID。
- Logins：一组 provider name 到 provider tokens 的映射，provider token 可以任意可以区分用户的字符串，比如 Authing 用户池用户 ID。
"Logins": {
    "<authing-userpool-id>.authing.cn": "5ccb24701bbaf00d50ced851" // Authing 用户池 ID
}

我们能从请求返回数据中 获得 IdentityId 和 Token。这样，我们就在 Authing 用户池用户 和 Cognito Identity ID 之间构建起了联系。接着可以使用 GetCredentialsForIdentity 获取 credentials，从而访问相关资源。

### IAM

IAM(Identity and Access Management) 管理 Users、Groups、 Roles 对 AWS 资源的访问权限，通过给 Role 添加相关权限，达到使用相关 AWS 资源的目的。

例如，新建 Cognito Identity Pool 的时候，会默认创建两个 role：

![](http://lcjim-img.oss-cn-beijing.aliyuncs.com/2019-12-18-181645.jpg)

可以给此 role 添加相关权限，比如：

![](http://lcjim-img.oss-cn-beijing.aliyuncs.com/2019-12-18-181702.jpg)

通过集成 Authing 与 Cognito Identity Pool，我们在 Authing User ID 与 Cognito Identity ID 之间构建起了映射关系。而每个 Identity ID，可以拥有不同的 Role。不同的 Role，具备不同的 AWS 资源访问权限。这也就将 Authing 和 AWS 的各种服务结合了起来。

### S3（Simple Storage Service）

下面举一个具体的例子：用户使用 Authing 登录之后，会得到一个唯一的 Authing User ID，通过 `GetOpenIdTokenForDeveloperIdentity`，将 Authing User ID 与 Cognito Identity ID 对应起来。通过以下 role permissions 以及 bucket policy，实现每个 Authing 用户能且仅能对 `users/<cognito-identity-id>` 目录的文件进行增删改查操作。

Bucket Policy 如下：
```json
{
    "Version": "2012-10-17",
    "Id": "Policy1576670578319",
    "Statement": [
        {
            "Sid": "ListYourObjects",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws-cn:s3:::authing-aws-demo",
            "Condition": {
                "StringLike": {
                    "s3:prefix": "users/${cognito-identity.amazonaws.com:sub}"
                }
            }
        },
        {
            "Sid": "ReadWriteDeleteYourObjects",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws-cn:s3:::authing-aws-demo/users/${cognito-identity.amazonaws.com:sub}",
                "arn:aws-cn:s3:::authing-aws-demo/users/${cognito-identity.amazonaws.com:sub}/*"
            ]
        }
    ]
}
```

role rermissions 如下：

![](http://lcjim-img.oss-cn-beijing.aliyuncs.com/2019-12-18-182358.png)

效果截图：

点击文件上传可以上传文件到个人的特定文件夹。

![](http://lcjim-img.oss-cn-beijing.aliyuncs.com/2019-12-18-182542.png)

可以通过 [https://sample.authing.cn/aws-demo/](https://sample.authing.cn/aws-demo/) 访问在线 Demo

## 常见问题

如果需要在线技术支持，可访问[官方论坛](https://forum.authing.cn/). 此仓库的 issue 仅用于上报 Bug 和提交新功能特性。

## 开源共建

- Fork 此仓库
- 创建自己的 git 分支 (git checkout -b my-new-feature)
- 提交你的修改 (git commit -am 'Add some feature')
- 将修改内容推送到远程分支 (git push -u origin my-new-feature)
- 创建一个 Pull Request

## 贡献

https://github.com/Authing/.github/blob/main/CONTRIBUTING.md

## 开源许可

[MIT](https://opensource.org/licenses/MIT)

Copyright (c) 2019-present, Authing
