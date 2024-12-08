import libfoo.Foo;

class MyFirstJavaProgram // The class name must match the target name of `java_binary` rule.
{
    public static void main(String[] args) {
        System.out.println("Hello World!");
        Foo.foo();
        Foo.bar();
    }
}
