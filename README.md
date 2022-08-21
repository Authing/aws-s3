# Authing - aws-s3-demo
<div align=center>
  <img width="250" src="https://files.authing.co/authing-console/authing-logo-new-20210924.svg" />
</div>

<div align="center">
    <a href="https://forum.authing.cn/" target="_blank"><img src="https://img.shields.io/badge/chat-forum-blue" /></a>
    <a href="https://opensource.org/licenses/MIT" target="_blank"><img src="https://img.shields.io/badge/License-MIT-success" alt="License"></a>
</div>

**English** | [简体中文](./README.zh_CN.md)

## Introduction
Authing Integration with AWS Services DEMO

## Reference
- [Authing](https://authing.cn)
- [Demo online address](https://sample.authing.cn/aws-demo/)

## Install

```sh
yarn install
```

## Usage

```sh
node index.js
```

## Integrating AWS Services with Authing

Authing is a developer-friendly, highly scalable identity cloud service with over 1 million users authenticated and authorized by Authing every month. This sharing will introduce how common enterprise authentication and authorization scenarios can meet the needs of local Chinese users for Cognito User Pool and provide localized services. At the same time, Authing will explain how Authing integrates with AWS Cognito Identity Pool and provide a demo of using S3 resources.

### Cognito Identity Pool

The Cognito User Pool is responsible for authentication. End-users can complete the registration and login process through the user pool.

The Cognito Identity Pool is responsible for authorization (access control), granting the right to use AWS resources to end users.

Although Amazon Web Services (AWS) is the world's number one cloud computing vendor in terms of market share, its products are not flawless, and Cognito (AWS's authentication solution) and its accompanying Chinese documentation is a counterfactual. Of course, in addition to not being easy to use, there are also problems such as slow access speeds and inapplicability to the Chinese market.

The Authing User Pool can replace the Cognito User Pool and build a bridge between domestic users and AWS resources.

When creating an AWS Identity Pool, you can configure custom Authentication providers, here we set the Developer provider name to `<authing-userpool-id>.authing.cn` format.

![](http://lcjim-img.oss-cn-beijing.aliyuncs.com/2019-12-18-181525.jpg)

![](http://lcjim-img.oss-cn-beijing.aliyuncs.com/2019-12-18-181549.jpg)

There are three parties involved in the entire process: the end user, Authing, and AWS, and the process is as follows.
- End-user authentication is done using the Authing user pool
- Authing developers call AWS' GetOpenIdTokenForDeveloperIdentity interface on the server side to get the IdentityId and Token.
- The end user calls GetCredentialsForIdentity to exchange tokens for the credentials needed to access AWS resources.

GetOpenIdTokenForDeveloperIdentity requires the following parameters.
- IdentityPoolId：Your AWS Identity Pool ID.
- Logins：A set of provider name to provider tokens mapping, provider token can be any string that can distinguish users, such as Authing user pool user ID.
"Logins": {
    "<authing-userpool-id>.authing.cn": "5ccb24701bbaf00d50ced851" // Authing userpool ID
}

We can get the IdentityId and Token from the request return data, so we have a link between the Authing user pool user and the Cognito Identity ID. We can then use GetCredentialsForIdentity to get credentials to access the relevant resources.

### IAM

IAM (Identity and Access Management) manages the access rights of Users, Groups, and Roles to AWS resources by adding related rights to Roles for the purpose of using related AWS resources.

For example, when a new Cognito Identity Pool is created, two roles are created by default.

![](http://lcjim-img.oss-cn-beijing.aliyuncs.com/2019-12-18-181645.jpg)

Permissions can be added to this role, e.g.

![](http://lcjim-img.oss-cn-beijing.aliyuncs.com/2019-12-18-181702.jpg)

By integrating Authing with the Cognito Identity Pool, we build a mapping between Authing User IDs and Cognito Identity IDs. Each Identity ID can have a different Role, and each Role has different access to AWS resources. This also combines Authing with AWS services.

### S3（Simple Storage Service）

Here is a concrete example: after a user logs in with Authing, he/she will get a unique Authing User ID, and the Authing User ID will be matched with the Cognito Identity ID by `GetOpenIdTokenForDeveloperIdentity`. With the following role permissions and bucket policy, each Authing user can add, delete, and check only files in the `users/<cognito-identity-id>` directory.

The Bucket Policy is as follows.
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

The role rermissions are as follows.

![](http://lcjim-img.oss-cn-beijing.aliyuncs.com/2019-12-18-182358.png)

Screenshot of the effect.

Clicking File Upload allows you to upload files to a specific folder for an individual.

![](http://lcjim-img.oss-cn-beijing.aliyuncs.com/2019-12-18-182542.png)

The online demo can be accessed at [https://sample.authing.cn/aws-demo/](https://sample.authing.cn/aws-demo/)

## Questions

For questions and support please use the [official forum](https://forum.authing.cn/). The issue list of this repo is exclusively for bug reports and feature requests.

## Contribution

- Fork it
- Create your feature branch (git checkout -b my-new-feature)
- Commit your changes (git commit -am 'Add some feature')
- Push to the branch (git push -u origin my-new-feature)
- Create new Pull Request
## Contribute

https://github.com/Authing/.github/blob/main/CONTRIBUTING.md#English


## License

[MIT](https://opensource.org/licenses/MIT)

Copyright (c) 2019-present, Authing
