# 做着玩的
## 懂得都懂

-----

###
VS CF的成本大于收益 by 2022-12-15

##### 自用demo.py脚本

```
python demo.py
```

##### 用于桌面ubuntu环境下redis持久化刷新cf_token,配合其他服务调用使用

-----
初始化环境
```
#需要先安装ruby 3.1.3

gem install bundler
# 第一次运行在目录下执行
bundle
bundle exec rake db:create
bundle exec rake db:migrate

```

-----
### 执行

```
./app
```
------
### 其他

##### 用处
###### 忽略一些限制和策略
###### 用sqlite存储对话数据,随时从本地开始对话
###### 第一次拿到cookies后不用梯子
###### chrome f12查看请求直接复制cookies后就可本地使用
###### 数据只有你自己本地和openai知道(

###### Chatgpt::Chrome.new ruby版本的undetected_chromedriver,用于过cf的检测,通过率90%

[undetected_chromedriver过验证逻辑完全借鉴参考py版本](https://github.com/ultrafunkamsterdam/undetected-chromedriver)

```ruby
con = first_call '你好' #进行第一次会话
con = last #最近的一挑会话数据
con = last(3) #最近的第三条会话数据
con = con.reply '在吗?' #回复这条对话,con对象会变为最新的对话
con #查看con对象详细信息
con = Conversation.find(id) #查找某个id的conversation 参考active record文档
chathelp #查看此帮助
export_all #导出本地数据
flash_cf_clearance #刷新cf_clearance
con.export #导出某条对话树祖先链全部记录
```
