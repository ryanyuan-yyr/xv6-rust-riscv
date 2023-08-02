use super::rust_header::*;
use core::sync::atomic;
use core::cell::UnsafeCell;
use core::ops::Deref;
use core::ops::DerefMut;

pub struct SpinLock<T> {
    lock: atomic::AtomicBool,
    data: UnsafeCell<T>,
    cpu: *const cpu,
}

impl<T> SpinLock<T> {
    pub const fn new(data: T) -> Self {
        Self {
            lock: atomic::AtomicBool::new(false),
            data: UnsafeCell::new(data),
            cpu: unsafe { core::ptr::null() },
        }
    }

    /// Optimized spinning lock which first read the lock non-atomically, then try to atomically cmpxchg the lock to true.
    /// If the lock is already true, it will spin until the lock is released.
    pub fn lock(&mut self) -> SpinLockGuard<T> {
        unsafe {
            push_off();
        }
        loop {
            if !self.lock.load(atomic::Ordering::Acquire) {
                if self
                    .lock
                    .compare_exchange(
                        false,
                        true,
                        atomic::Ordering::Acquire,
                        atomic::Ordering::Relaxed,
                    )
                    .is_ok()
                {
                    break;
                }
            }
        }
        self.cpu = unsafe { mycpu() };
        SpinLockGuard { lock: self }
    }

    pub fn holding(&self) -> bool {
        self.lock.load(atomic::Ordering::Relaxed) && self.cpu == unsafe { mycpu() }
    }
}

pub struct SpinLockGuard<'a, T> {
    lock: &'a mut SpinLock<T>,
}

impl<'a, T> Drop for SpinLockGuard<'a, T> {
    fn drop(&mut self) {
        unsafe {
            pop_off();
        }
        self.lock.cpu = unsafe { core::ptr::null() };
        self.lock.lock.store(false, atomic::Ordering::Release);
    }
}

impl<'a, T> Deref for SpinLockGuard<'a, T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        unsafe { &*self.lock.data.get() }
    }
}

impl<'a, T> DerefMut for SpinLockGuard<'a, T> {
    fn deref_mut(&mut self) -> &mut Self::Target {
        unsafe { &mut *self.lock.data.get() }
    }
}

unsafe impl<T: Send> Send for SpinLock<T> {}
unsafe impl<T: Send> Sync for SpinLock<T> {}
