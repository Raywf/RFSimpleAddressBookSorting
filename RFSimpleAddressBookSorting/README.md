###### README.

iOS中/英/韩简单通讯录排序(Objective-C)
PS，仅考虑首个字符的排序问题，同时未考虑性能优化的问题

1.英文通讯录排序；
    a.直接取出首个字符，转成大写字母并将其作为key，按Key存入相应数组即可，

2.中文通讯录排序；
    a.首先取出首个字符，
    b.利用CFStringTransform方法获得中文字对应的拼音首字母，因为多音字的问题，
      需要额外针对常用的多音字取某一常用音的处理，详见方法 - (NSString *)transformMandarinToLatin:(NSString *)hanzi
    c.将字母转成大写，按key将原始字符串存入相应数组，

3.韩文通讯录排序；
    a.首先取出首个字符，
    b.确定通讯录需要的key为韩文19个初始辅音，
    c.利用NSString中的方法characterAtIndex:将首个字符进行（ASCII转Unicode）处理，并获得一个Unicode值，
    d.根据（资料参考2.）提到的资料， 利用公式 (int)((Unicode - 44032) / 588) 来解构，
    e.在初始辅音数组中找到对应下标的初始辅音字符，
    f.将上面解构出的初始辅音字符作为key，按key将原始字符串存入相应数组，

>资料参考：
1.[Sorting and Grouping of Korean Character (Not familiar with Korean language)](https://stackoverflow.com/questions/30702699/sorting-and-grouping-of-korean-character-not-familiar-with-korean-language)
2.[Korean language and computers](https://en.wikipedia.org/wiki/Korean_language_and_computers#Example)
3.[Unicode编码转换，ASCII转Unicode](http://tool.chinaz.com/Tools/Unicode.aspx)
4.[NSString, characterAtIndex:](https://developer.apple.com/documentation/foundation/nsstring/1414645-characteratindex)
5.[CFString](https://developer.apple.com/documentation/corefoundation/cfstring-rfh)
