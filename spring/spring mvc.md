### DispatcherServlet

在Spring中，ContextLoaderListener只是辅助功能，用于**创建WebApplicationContext类型实例**，而真正的逻辑实现其实是在DispatcherServlet中进行的，DispatcherServlet是实现servlet接口的实现类。servlet是一个Java编写的程序，此程序是基于HTTP协议的，在服务器端运行的（如Tomcat），是按照servlet规范编写的一个Java类。主要是处理客户端的请求并将其结果发送到客户端。servlet的生命周期是由servlet的容器来控制的，它可以分为3个阶段：初始化、运行和销毁。

（1）初始化阶段。

● servlet容器加载servlet类，把servlet类的.class文件中的数据读到内存中。

● servlet容器创建一个ServletConfig对象。ServletConfig对象包含了servlet的初始化配置信息。

● servlet容器创建一个servlet对象。

● servlet容器调用servlet对象的init方法进行初始化。

（2）运行阶段。

当servlet容器接收到一个请求时，servlet容器会针对这个请求创建servletRequest和servletResponse对象，然后调用service方法。并把这两个参数传递给service方法。service方法通过servletRequest对象获得请求的信息。并处理该请求。再通过servletResponse对象生成这个请求的响应结果。然后销毁servletRequest和servletResponse对象。我们不管这个请求是post提交的还是get提交的，最终这个请求都会由service方法来处理。

（3）销毁阶段。

当Web应用被终止时，servlet容器会先调用servlet对象的destrory方法，然后再销毁servlet对象，同时也会销毁与servlet对象相关联的servletConfig对象。我们可以在destroy方法的实现中，释放servlet所占用的资源，如关闭数据库连接