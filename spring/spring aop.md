对于代理类的创建及处理，Spring委托给了**ProxyFactory**去处理，而在此函数中主要是对ProxyFactory的初始化操作，进而对真正的创建代理做准备，这些初始化操作包括如下内容。

- （1）获取当前类中的属性。
- （2）添加代理接口。
- （3）封装Advisor并加入到ProxyFactory中。
- （4）设置要代理的类。
- （5）当然在Spring中还为子类提供了定制的函数customizeProxyFactory，子类可以在此函数中进行对ProxyFactory的进一步封装。
- （6）进行获取代理操作。

**創建代理：**

```
ProxyCreatorSupport#createAopProxy
protected final synchronized AopProxy createAopProxy() {
		if (!this.active) {
			activate();
		}
		return getAopProxyFactory().createAopProxy(this);
	}
	
DefaultAopProxyFactory#createAopProxy
@Override
	public AopProxy createAopProxy(AdvisedSupport config) throws AopConfigException {
		if (config.isOptimize() || config.isProxyTargetClass() || 				   hasNoUserSuppliedProxyInterfaces(config)) {
			Class<?> targetClass = config.getTargetClass();
			if (targetClass == null) {
				throw new AopConfigException("TargetSource cannot determine target class: " + "Either an interface or a target is required for proxy creation.");
			}
			if (targetClass.isInterface() || Proxy.isProxyClass(targetClass)) {
				return new JdkDynamicAopProxy(config);
			}
			return new ObjenesisCglibAopProxy(config);
		}
		else {
			return new JdkDynamicAopProxy(config);
		}
	}


```

- 如果目标对象实现了接口，默认情况下会采用JDK的动态代理实现AOP。

  ●  如果目标对象实现了接口，可以强制使用CGLIB实现AOP。

  ●  如果目标对象没有实现了接口，必须采用CGLIB库，Spring会自动在JDK动态代理和CGLIB之间转换。



**如何强制使用CGLIB实现AOP**？

（1）添加CGLIB库，Spring_HOME/cglib/*.jar。

（2）在Spring配置文件中加入<aop:aspectj-autoproxy proxy-target-class="true"/>。

**JDK动态代理和CGLIB字节码生成的区别？**

● JDK动态代理只能对实现了接口的类生成代理，而不能针对类。

● CGLIB是针对类实现代理，主要是对指定的类生成一个子类，覆盖其中的方法，因为是继承，所以该类或方法最好不要声明成final。