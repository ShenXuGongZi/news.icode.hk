news.icode.hk 修改版 请勿直接使用。作为备份用

下面简介一下安装教程，对这个程序有兴趣的朋友可以试试


以下安装过程在Ubuntu Server 12.04 下进行，其它系统会有些许不同，请自行调整。


一、安装Hacker News


安装arc所需软件


    $ apt-get install racket rlwrap

拷贝arc到服务器上

	$ git clone http://github.com/nex3/arc

测试运行news.arc
<pre>
$ cd arc
$ mkdir arc
$ echo "yourname">arc/admins
$ mzscheme -f as.scm
arc> (load "lib/news.arc")
arc> (nsv)
</pre>
这里的yourname是你自己希望使用的管理员名字。

登录news

访问链接：http://ip.to.server:8080/，点击login可创建用户，需要创建一个管理员来管理系统。

二、系统设置

设置自启动

	touch /usr/bin/arc
<pre>

#! /bin/sh
ARC_DIR="/home/yourpath/arc/"
cd $ARC_DIR
rlwrap mzscheme -qr ${ARC_DIR}as.scm $@
</pre>

	touch /home/yourpath/loadnews.arc
<pre>
#!/usr/bin/env arc
(load "lib/news.arc")
(nsv)
</pre>

在/etc/rc.local中加入：

	sudo -u youraccount -i /home/yourpath/loadnews.arc &

这里的yourpath是你使用的路径，youraccount是你运行arc的帐户。

配置nginx端口转发
<pre>
server {
listen 80;
server_name localhost;

location / {
proxy_pass http://127.0.0.1:8080;
proxy_set_header Host $host:8080;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Via "XFOCUS";
}
}
</pre>
Apache配置也类似，网上更多Apache端口转发的设置资料，可自行查找。

三、细节调整

新窗口打开链接

大概1014行：
<pre>
(let toself (blank url)
(tag (a target "_blank" href (if toself
(item-url s!id)
</pre>
502问题

如果你有前端Nginx代理，news有个自动保护机制，一旦单个Ip特定请求时间超过阈值，就会502，调整该值：

lib/srv.arc第90行，将250改大：
<pre>
(def abusive-ip-core (ip)
(and (only.> (requests/ip* ip) 250)
</pre>
还有许多个性就见仁见智了，可以参考Fenng做的Starup News，感谢Fenng 

四、更多Hacker News相关信息

移动版本

如果后续希望做移动版本，可以参考前人的开源代码：
```
IOS Client For Hacker News：https://github.com/Xuzz/newsyc/
Android Client For Hacker News：https://github.com/manmal/hn-android
Android Client For Hacker News:https://github.com/bishopmatthew/HackerNews
Android Client For Starup News：https://github.com/halzhang/StartupNews
```
备份

只需要备份整个arc目录即可，数据在arc/arc目录下；

防spam

系统spam较少，可参考作者文章：http://www.paulgraham.com/spam.html

