# Spring Framework



## 2.spring IOC



### 2.1 spring ioc 依赖来源

- 自定义bean
- 容器内建Bean对象
- 容器内建依赖

### 2.2 ApplicationContext 除了IOC容器角色，还有提供：

- 面向切面(AOP)
- 配置元信息 （Configuration Metadata）
- 资源管理(Resources)
- 事件 (Events)
- 国际化
- 注解
- Environment抽象

BeanFactory 是Spring底层IOC容器，ApplicationContex是具备应用特性的BeanFactory超集

### 2.3 spring Ioc 容器生命周期

### 2.4 BeanFactory 与 FactoryBean？

BeanFactory 是 IoC 底层容器 

FactoryBean 是 创建 Bean 的一种方式，帮助实现复杂的初始化逻辑



## 3.Spring Bean

### 3.1BeanDefiniton

BeanDeafinition 是Spring Framework中定义Bean的配置元信息接口，包含：

- bean 的类名
- Bean 行为配置元素，如作用域，自动绑定的模式，生命周期回调等
- 其他Bean引用，有可称合作者（collaborators）或者依赖（dependencies）
- 配置设置，比如Bean属性（Properties）

| 属性（Property）         | 说明                                           |
| ------------------------ | ---------------------------------------------- |
| Destruction method       | Bean 销毁回调方法名称                          |
| Class                    | Bean全类名，必须是具体类，不能用抽象类或者接口 |
| Name                     | Bean的名称或者ID                               |
| Scope                    | Bean的作用域（如:singleton,prototype等）       |
| Constructor arguments    | Bean构造器参数（用于依赖注入）                 |
| Properties               | Bean 属性设置（用于依赖注入）                  |
| Autowiring mode          | Bean 自动绑定模式（如：通过名称ByName）        |
| Lazy initialization mode | Bean 延迟初始化模式（延时和非延时）            |
| initialization method    | Bean 初始化回调方法名称                        |

