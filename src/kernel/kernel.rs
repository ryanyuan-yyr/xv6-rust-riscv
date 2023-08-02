#![no_std]
#![no_main]
#![allow(non_camel_case_types)]

include!("../include.rs");

#[path = "../../build/kernel/rust_header.rs"]
mod rust_header;
mod proc;
mod spinlock;
mod log;
mod bio;
