#![no_std]
#![no_main]

include!("../include.rs");
// include!("../../build/kernel/rust_header.rs");
// include!("../../build/user/rust_header.rs");

extern "C" {
    pub fn open(path: *const u8, flags: i32) -> i32;
    pub fn read(fd: i32, buf: *mut u8, len: usize) -> i32;
    pub fn write(fd: i32, buf: *const u8, len: usize) -> i32;
    pub fn close(fd: i32) -> i32;
    pub fn mknod(path: *const u8, dev: i32, flags: i32) -> i32;
    pub fn dup(fd: i32) -> i32;
    pub fn fork() -> i32;
    pub fn exit(code: i32) -> !;
    pub fn wait(ptr: *mut i32) -> i32;
    pub fn printf(format: *const u8, ...) -> i32;
    pub fn exec(path: *const u8, argv: *const *const u8) -> i32;
}

#[no_mangle]
pub extern "C" fn main() {
    let argv = [b"sh\0".as_ptr(), 0 as *const u8];
    unsafe {
        let mut pid;
        let mut wpid;
        if open(b"console\0".as_ptr(), O_RDWR) < 0 {
            mknod(b"console\0".as_ptr(), CONSOLE, 0);
            open(b"console\0".as_ptr(), O_RDWR);
        }
        dup(0);
        dup(0);
        loop {
            printf(b"init: starting sh\n\0".as_ptr());
            pid = fork();
            if pid < 0 {
                printf(b"init: fork failed\n\0".as_ptr());
                exit(-1);
            }
            if pid == 0 {
                exec(b"sh\0".as_ptr(), &argv as *const *const u8);
                printf(b"init: exec sh failed\n\0".as_ptr());
                exit(-1);
            }
            loop {
                wpid = wait(0 as *mut i32);
                if wpid == pid {
                    break;
                }
                if wpid < 0 {
                    printf(b"init: wait failed\n\0".as_ptr());
                    exit(-1);
                }
            }
        }
    }
}
