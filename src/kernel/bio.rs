use super::rust_header::*;
use super::spinlock::*;

struct BufCache {
    buf: [buf; NBUF as usize],
    head: buf,
}

static mut bcache: core::mem::MaybeUninit<SpinLock<BufCache>> = core::mem::MaybeUninit::uninit();

#[no_mangle]
pub extern "C" fn binit() {
    let mut head = unsafe { core::mem::transmute::<_, buf>([0u8; core::mem::size_of::<buf>()]) };

    let mut buf = [head; NBUF as usize];

    head.prev = &mut head as *mut buf;
    head.next = &mut head as *mut buf;

    for b in buf.iter_mut() {
        b.prev = head.next;
        b.prev = &mut head as *mut buf;
        unsafe {
            initsleeplock(&mut b.lock as *mut _, b"buffer\0".as_ptr().cast_mut());
        }
        (unsafe { *head.next }).prev = b as *mut buf;
        head.next = b as *mut buf;
    }

    unsafe {
        bcache.write(SpinLock::new(BufCache { buf, head }));
    }
}

fn bget(dev: u32,blockno: u32)->&'static mut buf{
    let mut bcache = unsafe { bcache.assume_init_mut() }.lock();
    
}
