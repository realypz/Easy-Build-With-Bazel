fn multiply(a: i32, b: i32) -> i32 {
    return a * b;
}

fn main() {
    println!("Hello World!");

    let ten = 10;
    let three = 3;

    // println is a macro. `!` means using a macro, not a function.
    println!("multiply: {} * {} = {}", ten, three, multiply(ten, three));

    let mut a = 0;
    loop {
        if a == 5 {
            break;
        }
        a = a + 1;
    }

    let devision = 5 as f32 / 3 as f32;
    println!("{}", devision);

    use libfoo::Greeter; // NOTE: libfoo maches the Bazel target name //rust:libfoo
    let greeter = Greeter::new("Rust: Hello");
    greeter.greet("World!");
}
