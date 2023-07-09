#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}

const CONSOLE: i32 = 1;
const O_RDONLY: i32 = 0x000;
const O_WRONLY: i32 = 0x001;
const O_RDWR: i32 = 0x002;
const O_CREATE: i32 = 0x200;
const O_TRUNC: i32 = 0x400;
