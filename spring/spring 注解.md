### **@Autowired 与@Resource的区别**

**@Autowired按byType自动注入，而@Resource默认按 byName自动注入**

@Resource有两个属性是比较重要的，分是name和type，Spring将@Resource注解的name属性解析为bean的名字，而type属性则解析为bean的类型.

@Autowired是根据类型进行自动装配的。当Spring上下文中存在不止一个相同类型的bean时，抛出BeanCreationException异常。

使用@Qualifier配合@Autowired



### @PostConstruct 

相当于init-method,使用在方法上，当Bean初始化时执行。



### @PreDestroy 

相当于destory-method，使用在方法上，当Bean销毁时执行。



### @Transactional  

声明式事务

 

## @Controller

定义控制层Bean,如Action



## @Service    

定义业务层Bean



### @Repository   

定义DAO层Bean



### @Component  



### @service("service")括号中的service有什么用

service  是有用的相当于 xml配置中得bean  id = service  也可以不指定 不指定相当于 bean id =  com. service.service 就是这个类的全限定名,表示给当前类命名一个别名，方便注入到其他需要用到的类中；不加的话，默认别名就是当前类名，但是首字母小写 .