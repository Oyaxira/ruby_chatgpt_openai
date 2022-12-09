# 做着玩的
## 懂得都懂


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
