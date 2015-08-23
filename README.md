# ZGVLSDK
微米通讯云SDK IOS版

用到的第三方框架:

AFNetworking

FMDB

Qiniu(七牛云储存)

使用方法:

将ZGVL文件夹到入到项目,导入ZGVL.h文件即可

你应该在应用启动后调用[ZGVL start]方法,以启动自动收取聊天消息模块,

收到新消息时会发送"ZGVLReceivedNewChatMessageNotification"通知

详细使用说明请查看ZGVL.h文件
