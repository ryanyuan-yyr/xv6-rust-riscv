use std::path::PathBuf;

fn main() {
    let args = std::env::args().collect::<Vec<String>>();
    if args.len() < 3 {
        println!("Usage: {} <input>+ <output>", args[0]);
        std::process::exit(1);
    }

    // let mut content = String::new();
    let mut bind = bindgen::Builder::default().use_core();
    for input in &args[1..args.len() - 1] {
        // content += &std::fs::read_to_string(input).unwrap();
        bind = bind.header(input);
    }
    let output = PathBuf::from(&args[args.len() - 1]);

    // .header_contents(&output.file_name().unwrap().to_str().unwrap(), &content)
    let res = bind.generate().unwrap();
    res.write_to_file(output).unwrap();
}
