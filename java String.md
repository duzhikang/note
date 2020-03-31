# java String

## 1. String（**字符串常量**）

```java
public final class String
    implements java.io.Serializable, Comparable<String>, CharSequence {
    /** The value is used for character storage. */
    private final char value[];
}
```

String 是一个不可变类，底层通过一个数组维护。

字符串的比较：

== 比较地址，equals 比较的内容。

## 1.1 字符串常量池

`JVM`为了提高性能和减少内存开销，为字符串开辟一个字符串常量池，类似于缓存区。创建字符串常量时，检查字符串常量池是否存在该字符串，存在该字符串，返回引用实例，不存在，实例化该字符串并放入池中。常量池存在于方法区（永久代）。

实现基础：

- 实现该优化的基础是因为字符串是不可变的，可以不用担心数据冲突进行共享
- 运行时实例创建的全局字符串常量池中有一个表，总是为池中每个唯一的字符串对象维护一个引用,这就意味着它们一直引用着字符串常量池中的对象，所以，在常量池中的这些字符串不会被垃圾收集器回收。

运行是的数据区主要分为：堆，栈，方法区。

- 堆
  - 存储的是对象，每个对象都包含一个与之对应的class
  - JVM只有一个堆区(heap)被所有线程共享，堆中不存放基本类型和对象引用，只存放对象本身
  - 对象的由垃圾回收器负责回收，因此大小和生命周期不需要确定
- 栈
  - 每个线程包含一个栈区，栈中只保存基础数据类型的对象和自定义对象的引用(不是对象)
  - 每个栈中的数据(原始类型和对象引用)都是私有的
  - 栈分为3个部分：基本类型变量区、执行环境上下文、操作指令区(存放操作指令)
  - 数据大小和生命周期是可以确定的，当没有引用指向数据时，这个数据就会自动消失
- 方法区
  - 静态区，跟堆一样，被所有的线程共享
  - 方法区中包含的都是在整个程序中永远唯一的元素，如class，static变量

```
        String a = "a";
        String b = "b";
        String c = "ab";
        String d = "a" + "b";
        String e = a + b;
        String f = new String("ab");
        System.out.println(d == c);
        // 编译期不能确定e的值，运行时才能计算出e的值
        System.out.println(a + b == c);
```

面试题：String str4 = new String(“abc”) 创建多少个对象？

1. 在常量池中查找是否有“abc”对象
   - 有则返回对应的引用实例
   - 没有则创建对应的实例对象
2. 在堆中 new 一个 String("abc") 对象
3. 将对象地址赋值给str4,创建一个引用

## 2. StringBuffer和StringBuilder（**字符串变量**）

```

public final class StringBuffer
    extends AbstractStringBuilder
    implements java.io.Serializable, CharSequence
{

    /**
     * A cache of the last value returned by toString. Cleared
     * whenever the StringBuffer is modified.
     */
    private transient char[] toStringCache;
    // initial capacity of 16 characters.
    public StringBuffer() {
        super(16);
    }
    
    //apend都是通过数组的拷贝方法
    value = Arrays.copyOf(value,
                    newCapacity(minimumCapacity));
    StringBuffer线程安全，加了synchronized关键字。
```