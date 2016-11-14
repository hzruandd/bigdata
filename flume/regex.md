1.验证数字：
只能输入1个数字
 
  
表达式 ^\d$ 
描述 匹配一个数字 
匹配的例子 0,1,2,3 
不匹配的例子 
 
2.只能输入n个数字 
表达式 ^\d{n}$  例如^\d{8}$ 
描述 匹配8个数字 
匹配的例子 12345678,22223334,12344321 
不匹配的例子 
 
 
3.只能输入至少n个数字 
表达式 ^\d{n,}$ 例如^\d{8,}$ 
描述 匹配最少n个数字 
匹配的例子 12345678,123456789,12344321 
不匹配的例子 
 
 
4.只能输入m到n个数字 
表达式 ^\d{m,n}$ 例如^\d{7,8}$ 
描述 匹配m到n个数字 
匹配的例子 12345678,1234567 
不匹配的例子 123456,123456789
 
 
5.只能输入数字 
表达式 ^[0-9]*$ 
描述 匹配任意个数字 
匹配的例子 12345678,1234567 
不匹配的例子 E,清清月儿
 
 
6.只能输入某个区间数字 
表达式 ^[12-15]$ 
描述 匹配某个区间的数字 
匹配的例子 12,13,14,15 
不匹配的例子 
 
 
7.只能输入0和非0打头的数字 
表达式 ^(0|[1-9][0-9]*)$ 
描述 可以为0，第一个数字不能为0，数字中可以有0 
匹配的例子 12,10,101,100 
不匹配的例子 01,清清月儿,http://blog.csdn.net/21aspnet
 
 
8.只能输入实数 
表达式 ^[-+]?\d+(\.\d+)?$ 
描述 匹配实数 
匹配的例子 18,+3.14,-9.90 
不匹配的例子 .6,33s,67-99
 
 
9.只能输入n位小数的正实数 
表达式 ^[0-9]+(.[0-9]{n})?$以^[0-9]+(.[0-9]{2})?$为例 
描述 匹配n位小数的正实数 
匹配的例子 2.22 
不匹配的例子 2.222,-2.22,http://blog.csdn.net/21aspnet
 
 
10.只能输入m-n位小数的正实数 
表达式 ^[0-9]+(.[0-9]{m,n})?$以^[0-9]+(.[0-9]{1,2})?$为例 
描述 匹配m到n位小数的正实数 
匹配的例子 2.22,2.2 
不匹配的例子 2.222,-2.2222,http://blog.csdn.net/21aspnet
 
 
11.只能输入非0的正整数 
表达式 ^\+?[1-9][0-9]*$ 
描述 匹配非0的正整数 
匹配的例子 2,23,234 
不匹配的例子 0,-4,
 
 
12.只能输入非0的负整数 
表达式 ^\-[1-9][0-9]*$ 
描述 匹配非0的负整数 
匹配的例子 -2,-23,-234 
不匹配的例子 0,4,
 
 
13.只能输入n个字符 
表达式 ^.{n}$ 以^.{4}$为例 
描述 匹配n个字符，注意汉字只算1个字符 
匹配的例子 1234,12we,123清,清清月儿 
不匹配的例子 0,123,123www,http://blog.csdn.net/21aspnet/
 
 
14.只能输入英文字符 
表达式 ^.[A-Za-z]+$为例 
描述 匹配英文字符，大小写任意 
匹配的例子 Asp,WWW, 
不匹配的例子 0,123,123www,http://blog.csdn.net/21aspnet/
 
 
15.只能输入大写英文字符 
表达式 ^.[A-Z]+$为例 
描述 匹配英文大写字符 
匹配的例子 NET,WWW, 
不匹配的例子 0,123,123www,
 
 
16.只能输入小写英文字符 
表达式 ^.[a-z]+$为例 
描述 匹配英文大写字符 
匹配的例子 asp,csdn 
不匹配的例子 0,NET,WWW,
 
 
17.只能输入英文字符+数字 
表达式 ^.[A-Za-z0-9]+$为例 
描述 匹配英文字符+数字 
匹配的例子 1Asp,W1W1W, 
不匹配的例子 0,123,123,www,http://blog.csdn.net/21aspnet/
 
 
18.只能输入英文字符/数字/下划线 
表达式 ^\w+$为例 
描述 匹配英文字符或数字或下划线 
匹配的例子 1Asp,WWW,12,1_w 
不匹配的例子 3#,2-4,w#$,http://blog.csdn.net/21aspnet/
 
 
19.密码举例 
表达式 ^.[a-zA-Z]\w{m,n}$ 
描述 匹配英文字符开头的m-n位字符且只能数字字母或下划线 
匹配的例子 
不匹配的例子 
 
 
20.验证首字母大写 
表达式 \b[^\Wa-z0-9_][^\WA-Z0-9_]*\b 
描述 首字母只能大写 
匹配的例子 Asp,Net 
不匹配的例子 http://blog.csdn.net/21aspnet/
 
 
21.验证网址（带?id=中文）VS.NET2005无此功能 
表达式 ^http:\/\/([\w-]+(\.[\w-]+)+(\/[\w-   .\/\?%&=\u4e00-\u9fa5]*)?)?$
  
描述 验证带?id=中文 
匹配的例子 http://blog.csdn.net/21aspnet/,
http://blog.csdn.net?id=清清月儿 
不匹配的例子 
 
 
22.验证汉字 
表达式 ^[\u4e00-\u9fa5]{0,}$ 
描述 只能汉字 
匹配的例子 清清月儿 
不匹配的例子 http://blog.csdn.net/21aspnet/
 
 
23.验证QQ号 
表达式 [0-9]{5,9} 
描述 5-9位的QQ号 
匹配的例子 10000,123456 
不匹配的例子 10000w,http://blog.csdn.net/21aspnet/
 
 
24.验证电子邮件（验证MSN号一样） 
表达式 \w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)* 
描述 注意MSN用非hotmail.com邮箱也可以 
匹配的例子 aaa@msn.com 
不匹配的例子 111@1.   http://blog.csdn.net/21aspnet/
 
 
25.验证身份证号（粗验，最好服务器端调类库再细验证） 
表达式 ^[1-9]([0-9]{16}|[0-9]{13})[xX0-9]$ 
描述 
匹配的例子 15或者18位的身份证号，支持带X的 
不匹配的例子 http://blog.csdn.net/21aspnet/
 
 
26.验证手机号（包含159，不包含小灵通） 
表达式 ^13[0-9]{1}[0-9]{8}|^15[9]{1}[0-9]{8} 
描述 包含159的手机号130-139 
匹配的例子 139XXXXXXXX 
不匹配的例子 140XXXXXXXX,http://blog.csdn.net/21aspnet/
 
 
27.验证电话号码号（很复杂，VS.NET2005给的是错的） 
表达式（不完美） 方案一  ((\(\d{3}\)|\d{3}-)|(\(\d{4}\)|\d{4}-))?(\d{8}|\d{7})
方案二 (^[0-9]{3,4}\-[0-9]{3,8}$)|(^[0-9]{3,8}$)|(^\([0-9]{3,4}\)[0-9]{3,8}$)|(^0{0,1}13[0-9]{9}$)  支持手机号但也不完美 
描述 上海：02112345678   3+8位
上海：021-12345678
上海：(021)-12345678
上海：(021)12345678
郑州：03711234567    4+7位
杭州：057112345678    4+8位
还有带上分机号，国家码的情况
由于情况非常复杂所以不建议前台做100%验证，到目前为止似乎也没有谁能写一个包含所有的类型，其实有很多情况本身就是矛盾的。
如果谁有更好的验证电话的请留言
  
匹配的例子 
不匹配的例子 
 
 
28.验证护照 
表达式 (P\d{7})|G\d{8})
  
描述 验证P+7个数字和G+8个数字 
匹配的例子 
不匹配的例子 清清月儿,http://blog.csdn.net/21aspnet/
 
 
29.验证IP 
表达式 ^(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])$
  
描述 验证IP 
匹配的例子 192.168.0.1   222.234.1.4 
不匹配的例子 
 
 
30.验证域 
表达式 ^[a-zA-Z0-9]+([a-zA-Z0-9\-\.]+)?\.s|)$
  
描述 验证域 
匹配的例子 csdn.net   baidu.com  it.com.cn 
不匹配的例子 192.168.0.1 
 
 
31.验证信用卡 
表达式 ^((?:4\d{3})|(?:5[1-5]\d{2})|(?:6011)|(?:3[68]\d{2})|(?:30[012345]\d))[ -]?(\d{4})[ -]?(\d{4})[ -]?(\d{4}|3[4,7]\d{13})$
  
描述 验证VISA卡，万事达卡，Discover卡，美国运通卡 
匹配的例子 
不匹配的例子 
 
 
32.验证ISBN国际标准书号 
表达式 ^(\d[- ]*){9}[\dxX]$
  
描述 验证ISBN国际标准书号 
匹配的例子 7-111-19947-2 
不匹配的例子 
 
 
33.验证GUID全球唯一标识符 
表达式 ^[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}$
  
描述 格式8-4-4-4-12 
匹配的例子 2064d355-c0b9-41d8-9ef7-9d8b26524751 
不匹配的例子 
 
 
34.验证文件路径和扩展名 
表达式 ^([a-zA-Z]\:|\\)\\([^\\]+\\)*[^\/:*?"<>|]+\.txt(l)?$
  
描述 检查路径和文件扩展名 
匹配的例子 E:\mo.txt 
不匹配的例子 E:\ , mo.doc, E:\mo.doc ,http://blog.csdn.net/21aspnet/
 
 
35.验证Html颜色值 
表达式 ^#?([a-f]|[A-F]|[0-9]){3}(([a-f]|[A-F]|[0-9]){3})?$
  
描述 检查颜色取值 
匹配的例子 #FF0000 
不匹配的例子 http://blog.csdn.net/21aspnet/
 
^[1-9]\d*\.\d*|0\.\d*[1-9]\d*$
 
整数或者小数：^[0-9]+\.{0,1}[0-9]{0,2}$ 
只能输入数字："^[0-9]*$"。 
只能输入n位的数字："^\d{n}$"。 
只能输入至少n位的数字："^\d{n,}$"。 
只能输入m~n位的数字：。"^\d{m,n}$" 
只能输入零和非零开头的数字："^(0|[1-9][0-9]*)$"。 
只能输入有两位小数的正实数："^[0-9]+(.[0-9]{2})?$"。 
只能输入有1~3位小数的正实数："^[0-9]+(.[0-9]{1,3})?$"。 
只能输入非零的正整数："^\+?[1-9][0-9]*$"。 
只能输入非零的负整数："^\-[1-9][]0-9"*$。 
只能输入长度为3的字符："^.{3}$"。 
只能输入由26个英文字母组成的字符串："^[A-Za-z]+$"。 
只能输入由26个大写英文字母组成的字符串："^[A-Z]+$"。 
只能输入由26个小写英文字母组成的字符串："^[a-z]+$"。 
只能输入由数字和26个英文字母组成的字符串："^[A-Za-z0-9]+$"。 
只能输入由数字、26个英文字母或者下划线组成的字符串："^\w+$"。 
验证用户密码："^[a-zA-Z]\w{5,17}$"正确格式为：以字母开头，长度在6~18之间，只能包含字符、数字和下划线。 
验证是否含有^%&',;=?$\"等字符："[^%&',;=?$\x22]+"。 
只能输入汉字："^[\u4e00-\u9fa5]{0,}$" 
验证Email地址："^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"。 
验证InternetURL："^http://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$"。 
验证电话号码："^(\(\d{3,4}-)|\d{3.4}-)?\d{7,8}$"正确格式为："XXX-XXXXXXX"、"XXXX-XXXXXXXX"、"XXX-XXXXXXX"、"XXX-XXXXXXXX"、"XXXXXXX"和"XXXXXXXX"。 
验证身份证号（15位或18位数字）："^\d{15}|\d{18}$"。 
验证一年的12个月："^(0?[1-9]|1[0-2])$"正确格式为："01"～"09"和"1"～"12"。 
验证一个月的31天："^((0?[1-9])|((1|2)[0-9])|30|31)$"正确格式为；"01"～"09"和"1"～"31"。 
匹配中文字符的正则表达式： [\u4e00-\u9fa5] 
 
匹配双字节字符(包括汉字在内)：[^\x00-\xff] 
 
应用：计算字符串的长度（一个双字节字符长度计2，ASCII字符计1） 
String.prototype.len=function(){return this.replace(/[^\x00-\xff]/g,"aa").length;} 
 
匹配空行的正则表达式：\n[\s| ]*\r 
 
匹配html标签的正则表达式：<(.*)>(.*)<\/(.*)>|<(.*)\/> 
 
匹配首尾空格的正则表达式：(^\s*)|(\s*$) 
 
应用：javascript中没有像vbscript那样的trim函数，我们就可以利用这个表达式来实现，如下： 
 
String.prototype.trim = function() 
{ 
return this.replace(/(^\s*)|(\s*$)/g, ""); 
} 
 
利用正则表达式分解和转换IP地址： 
 
下面是利用正则表达式匹配IP地址，并将IP地址转换成对应数值的Javascript程序： 
 
function IP2V(ip) 
{ 
re=/(\d+)\.(\d+)\.(\d+)\.(\d+)/g //匹配IP地址的正则表达式 
if(re.test(ip)) 
{ 
return RegExp.$1*Math.pow(255,3))+RegExp.$2*Math.pow(255,2))+RegExp.$3*255+RegExp.$4*1 
} 
else 
{ 
throw new Error("Not a valid IP address!") 
} 
} 
 
不过上面的程序如果不用正则表达式，而直接用split函数来分解可能更简单，程序如下： 
 
var ip="10.100.20.168" 
ip=ip.split(".") 
alert("IP值是："+(ip[0]*255*255*255+ip[1]*255*255+ip[2]*255+ip[3]*1)) 
 
匹配Email地址的正则表达式：\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)* 
 
匹配网址URL的正则表达式：http://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)? 
 
 
利用正则表达式限制网页表单里的文本框输入内容： 
 
用正则表达式限制只能输入中文：onkeyup="value=value.replace(/[^\u4E00-\u9FA5]/g,'')" onbeforepaste="clipboardData.setData('text',clipboardData.getData('text').replace(/[^\u4E00-\u9FA5]/g,''))" 
 
用正则表达式限制只能输入全角字符： onkeyup="value=value.replace(/[^\uFF00-\uFFFF]/g,'')" onbeforepaste="clipboardData.setData('text',clipboardData.getData('text').replace(/[^\uFF00-\uFFFF]/g,''))" 
 
用正则表达式限制只能输入数字：onkeyup="value=value.replace(/[^\d]/g,'') "onbeforepaste="clipboardData.setData('text',clipboardData.getData('text').replace(/[^\d]/g,''))"
 
用正则表达式限制只能输入数字和英文：onkeyup="value=value.replace(/[\W]/g,'') "onbeforepaste="clipboardData.setData('text',clipboardData.getData('text').replace(/[^\d]/g,''))"
 
<input onkeyup="value=value.replace(/[^\u4E00-\u9FA5\w]/g,'')" onbeforepaste="clipboardData.setData('text',clipboardData.getData('text').replace(/[^\u4E00-\u9FA5\w]/g,''))" value="允许下划线,数字字母和汉字">
 
<script language="javascript"> 
if (document.layers)//触发键盘事件 
document.captureEvents(Event.KEYPRESS) 
 
function xz(thsv,nob){ 
if(nob=="2"){ 
window.clipboardData.setData("text","") 
alert("避免非法字符输入,请勿复制字符"); 
return false; 
} 
if (event.keyCode!=8 && event.keyCode!=16 && event.keyCode!=37 && event.keyCode!=38 && event.keyCode!=39 && event.keyCode!=40){ 
thsvv=thsv.value;//输入的值 
thsvs=thsvv.substring(thsvv.length-1);//输入的最后一个字符 
//thsvss=thsvv.substring(0,thsvv.length-1);//去掉最后一个错误字符 
if (!thsvs.replace(/[^\u4E00-\u9FA5\w]/g,'') || event.keyCode==189){//正则除去符号和下划线 key 
thsv.value='请勿输入非法符号 ['+thsvs+']'; 
alert('请勿输入非法符号 ['+thsvs+']'); 
thsv.value=""; 
return false; 
} 
} 
} 
 
</script> 
 
<input onkeyup="xz(this,1)" onPaste="xz(this,2)" value="">允许数字字母和汉字
 
<script language="javascript"> 
<!-- 
function MaxLength(field,maxlimit){ 
var j = field.value.replace(/[^\x00-\xff]/g,"**").length; 
//alert(j); 
var tempString=field.value; 
var tt=""; 
if(j > maxlimit){ 
for(var i=0;i<maxlimit;i++){ 
if(tt.replace(/[^\x00-\xff]/g,"**").length < maxlimit) 
tt = tempString.substr(0,i+1); 
else 
break; 
} 
if(tt.replace(/[^\x00-\xff]/g,"**").length > maxlimit) 
tt=tt.substr(0,tt.length-1); 
field.value = tt; 
}else{ 
; 
} 
} 
</script>
 
单行文本框控制<br /> 
<INPUT type="text" id="Text1" name="Text1" onpropertychange="MaxLength(this, 5)"><br /> 
多行文本框控制:<br /> 
<TEXTAREA rows="14" 
cols="39" id="Textarea1" name="Textarea1" onpropertychange="MaxLength(this, 15)"></TEXTAREA><br />
 
控制表单内容只能输入数字,中文.... 
<script> 
function test()  
{ 
if(document.a.b.value.length>50) 
{ 
alert("不能超过50个字符！"); 
document.a.b.focus(); 
return false; 
} 
} 
</script> 
<form name=a onsubmit="return test()"> 
<textarea name="b" cols="40" wrap="VIRTUAL" rows="6"></textarea> 
<input type="submit" name="Submit" value="check"> 
</form> 
 
只能是汉字 
<input onkeyup="value=value.replace(/[^\u4E00-\u9FA5]/g,'')"> 
 
只能是英文字符 
<script language=javascript> 
function onlyEng() 
{ 
if(!(event.keyCode>=65&&event.keyCode<=90)) 
  event.returnValue=false; 
} 
</script> 
 
<input onkeydown="onlyEng();"> 
<input name="coname" type="text" size="50" maxlength="35" class=input2 onkeyup="value=value.replace(/[\W]/g,'') "onbeforepaste="clipboardData.setData('text',clipboardData.getData('text').replace(/[^\d]/g,''))"> 
只能是数字 
<script language=javascript> 
function onlyNum() 
{ 
if(!((event.keyCode>=48&&event.keyCode<=57)||(event.keyCode>=96&&event.keyCode<=105))) 
//考虑小键盘上的数字键 
  event.returnValue=false; 
} 
</script> 
 
<input onkeydown="onlyNum();"> 
 
只能是英文字符和数字 
<input onkeyup="value=value.replace(/[\W]/g,'') "onbeforepaste="clipboardData.setData('text',clipboardData.getData('text').replace(/[^\d]/g,''))"> 
 
验证为email格式 
<SCRIPT LANGUAGE=Javascript RUNAT=Server> 
function isEmail(strEmail) { 
if (strEmail.search(/^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/) != -1) 
return true; 
else 
alert("oh"); 
} 
</SCRIPT> 
<input type=text onblur=isEmail(this.value)> 
 
屏蔽关键字(sex , fuck) - 已修改 
<script language="JavaScript1.2"> 
function test() { 
if((a.b.value.indexOf ("sex") == 0)||(a.b.value.indexOf ("fuck") == 0)){ 
  alert("五讲四美三热爱"); 
  a.b.focus(); 
  return false;} 
} 
</script> 
<form name=a onsubmit="return test()"> 
<input type=text name=b> 
<input type="submit" name="Submit" value="check"> 
</form> 
 
 
限制文本框里只能输入数字 
<input onkeyup="if(event.keyCode !=37 && event.keyCode != 39) value=value.replace(/\D/g,'');"onbeforepaste="clipboardData.setData('text',clipboardData.getData('text').replace(/\D/g,''))"> 
 
 手机号码：(^(\d{3,4}-)?\d{7,8})$|(13[0-9]{9})|(15[8-9]{9})
 
不会的也可以根据上面介绍的写出来了吧，只是得花点时间了。
 
  
 
验证数字的正则表达式集 
验证数字：^[0-9]*$
验证n位的数字：^\d{n}$
验证至少n位数字：^\d{n,}$
验证m-n位的数字：^\d{m,n}$
验证零和非零开头的数字：^(0|[1-9][0-9]*)$
验证有两位小数的正实数：^[0-9]+(.[0-9]{2})?$
验证有1-3位小数的正实数：^[0-9]+(.[0-9]{1,3})?$
验证非零的正整数：^\+?[1-9][0-9]*$
验证非零的负整数：^\-[1-9][0-9]*$
验证非负整数（正整数 + 0） ^\d+$
验证非正整数（负整数 + 0） ^((-\d+)|(0+))$
验证长度为3的字符：^.{3}$
验证由26个英文字母组成的字符串：^[A-Za-z]+$
验证由26个大写英文字母组成的字符串：^[A-Z]+$
验证由26个小写英文字母组成的字符串：^[a-z]+$
验证由数字和26个英文字母组成的字符串：^[A-Za-z0-9]+$
验证由数字、26个英文字母或者下划线组成的字符串：^\w+$
验证用户密码:^[a-zA-Z]\w{5,17}$ 正确格式为：以字母开头，长度在6-18之间，只能包含字符、数字和下划线。
验证是否含有 ^%&',;=?$\" 等字符：[^%&',;=?$\x22]+
验证汉字：^[\u4e00-\u9fa5],{0,}$
验证Email地址：^\w+[-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$
验证InternetURL：^http://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$ ；^[a-zA-z]+://(w+(-w+)*)(.(w+(-w+)*))*(?S*)?$
验证电话号码：^(\(\d{3,4}\)|\d{3,4}-)?\d{7,8}$：--正确格式为：XXXX-XXXXXXX，XXXX-XXXXXXXX，XXX-XXXXXXX，XXX-XXXXXXXX，XXXXXXX，XXXXXXXX。
验证身份证号（15位或18位数字）：^\d{15}|\d{}18$
验证一年的12个月：^(0?[1-9]|1[0-2])$ 正确格式为：“01”-“09”和“1”“12”
验证一个月的31天：^((0?[1-9])|((1|2)[0-9])|30|31)$  正确格式为：01、09和1、31。
整数：^-?\d+$
非负浮点数（正浮点数 + 0）：^\d+(\.\d+)?$
正浮点数  ^(([0-9]+\.[0-9]*[1-9][0-9]*)|([0-9]*[1-9][0-9]*\.[0-9]+)|([0-9]*[1-9][0-9]*))$
非正浮点数（负浮点数 + 0） ^((-\d+(\.\d+)?)|(0+(\.0+)?))$
负浮点数 ^(-(([0-9]+\.[0-9]*[1-9][0-9]*)|([0-9]*[1-9][0-9]*\.[0-9]+)|([0-9]*[1-9][0-9]*)))$
浮点数 ^(-?\d+)(\.\d+)?
