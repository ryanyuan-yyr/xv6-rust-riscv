use super::rust_header::*;

/// This does not need a lock because each CPU (thread) only access its own cpu struct.
/// Accessing thread's own cpu requires disabling interrupts, which prevents interrupt
/// handler from accessing this CPU structure.
#[no_mangle]
#[used]
pub static mut cpus: [cpu; NCPU as usize] =
    unsafe { core::mem::transmute([0u8; NCPU as usize * core::mem::size_of::<cpu>()]) };

#[no_mangle]
#[used]
pub static mut proc: [proc_; NPROC as usize] =
    unsafe { core::mem::transmute([0u8; NPROC as usize * core::mem::size_of::<proc_>()]) };
