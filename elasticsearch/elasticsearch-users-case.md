#一些国外优秀的elasticsearch使用案例

##Github

“Github使用Elasticsearch搜索20TB的数据，包括13亿的文件和1300亿行的代码”

这个不用介绍了吧，码农们都懂的，Github在2013年1月升级了他们的代码搜索，由solr转为elasticsearch，目前集群规模为26个索引存储节点和8个客户端节点（负责处理搜索请求），详情请看官方博客
https://github.com/blog/1381-a-whole-new-code-search

##Foursquare

”实时搜索5千万地点信息？Foursquare每天都用Elasticsearch做这样的事“

Foursquare是一家基于用户地理位置信息的手机服务网站，并鼓励手机用户同他人分享自己当前所在地理位置等信息。与其他老式网站不同，Foursquare用户界面主要针对手机而设计，以方便手机用户使用。

##SoundCloud

“SoundCloud使用Elasticsearch来为1.8亿用户提供即时精准的音乐搜索服务”

SoundCloud是一家德国网站，提供音乐分享社区服务，成长很快，Alexa世界排名已达第236位。你可以在线录制或上传任何声音到SoundCloud与大家分享，可在线上传也可以通过软件客户端来上传音乐文件，没有文件大小限制，但免费版限制上传音频总长不可超过2个小时播放时长，每首歌曲限最多100次下载。SoundCloud允许音乐通过Flash播放器方式嵌入到网页中。

##Fog Creek

“Elasticsearch使Fog Creek可以在400亿行代码中进行一个月3千万次的查询“

##StumbleUpon

”Elasticsearch是StumbleUpon的关键部件，它每天为社区提供百万次的推荐服务“

StumbleUpon是个能发现你喜欢的网页的网站，进去时先注册，注册完就选择你感兴趣的东西，它会自动帮你推荐一些网页，如果你喜欢这个网页就点喜欢按钮，按
stumble按钮就会推荐下一个网页。
目前其数据量达到 25亿，基本数据存储在HBase中，并用
elasticsearch建立索引，elasticsearch
在其中除了用在搜索功能还有在推荐和统计功能。之前他们是使用solr作为搜索，由于solr满足不了他们的业务增长需要而替换为
elasticsearch。

##Mozilla

Mozilla公司以火狐著名，它目前使用 WarOnOrange
这个项目来进行单元或功能测试，测试的结果以
json的方式索引到elasticsearch中，开发人员可以非常方便的查找 bug。
Socorro是Mozilla 公司的程序崩溃报告系统，一有错误信息就插入到 Hbase和Postgres
中，然后从 Hbase中读取数据索引到elasticsearch中，方便查找。

##Sony

Sony公司使用elasticsearch 作为信息搜索引擎

##Infochimps

“在 Infochimps，我们已经索引了25亿文档，总共占用 4TB的空间”。
Infochimps是一家位于德克萨斯州奥斯丁的创业公司，为大数据平台提供商。它主要提供基于hadoop的大数据处理方案。

