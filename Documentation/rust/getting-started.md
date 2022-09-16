# Getting Started
---

This document describes step-by-step commands to build, install, and insert a kernel written in Rust.

**Disclaimer | Since the kernel (re-)installation can break your system easily, I recommand using a VM for safety and convenience.**

_Note 1: All commands have been tested under a KVM/QEMU VM running Ubuntu server 18.04._

_Note 2: This document builds and installs the kernel and the kernel modules **from inside the VM**. If you want to generate Linux image directly from the source code natively on your machine and run it with QEMU/emulation, refer to [this link](https://linuxfoundation.org/webinars/writing-linux-kernel-modules-in-rust/)._

## Preparing development environment
We need to install rust related packages and dependencies that required for building kernel module in Rust.
_Note 3: If your environment is not ready for building Linux kernel, please check [this link](https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel) and install related packages/dependencies._

- Install rustc
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
  - Setup `$PATH` following _the instruction from the previous command_.
```bash
vim ~/.zshrc (OR ~/.bashrc, etc.)
```

- Install dependencies
```bash
rustup override set $(scripts/min-tool-version.sh rustc)\n
rustup component add rust-src
cargo install --locked --version $(scripts/min-tool-version.sh bindgen) bindgen
rustup component add rustfmt
rustup component add clippy
```

- Install llvm and clang ([Ref.](https://gist.github.com/kittywhiskers/a3395cb41206d8aa777ce0a8b722d37e))
```bash
sudo apt-get update
sudo apt-get install llvm

wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
echo "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-11 main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install libclang1-11 clang-11 lld-11
sudo ln -s /usr/bin/clang-11 /usr/bin/clang
sudo ln -s /usr/bin/lld-11 /usr/bin/lld
sudo ln -s /usr/bin/ld.lld-11 /usr/bin/ld.lld
```

- Check the environment/toolchain with the following command.
  - You should see the message `Rust is available!`
```bash
cd [PATH_TO_CLONED_REPO]
make LLVM=1 rustavailable
```

## Kernel compilation
To build Linux kernel, we need to prepare correct build configuration that supports Rust. You can do it by enabling Ruyt-related flags as follows:

- Configuration using `menuconfig`
  - General setup → Rust support (enable)
  - Kernel hacking → Sample kernel code → Rust samples → (enable samples as `m` (module); e.g, rust minimal)
- If you want to keep the same configuration of the currently running kernel, you can find the configuration file (`.config`)[at here](https://superuser.com/questions/287371/obtain-kernel-config-from-currently-running-linux-system). Note that you must enable the rust-related features above.
```bash
make LLVM=1 menuconfig
```

Now we are going to build the kernel and kernel modules including the ones written in Rust.
- Build and install the kernel and the kernel modules (it would take some time, up to an hour)
  - For any other kernel configuration options (kernel build script may ask some), I chose default values (by pressing enter/return key).
  - Example pathes you may want to take a look:
    - Path to the source code of the `rust_minimal` module: `[PATH_TO_REPO]/samples/rust/rust_minimal.rs`
    - Location of local build for the `rust_minimal` is `[PATH_TO_REPO]/samples/rust/rust_minimal.ko`
```
make headers_install
./build_kernel.sh
./build_kernel_modules.sh
```

## Testing out kernel modules
After rebooting to the newly installed kernel (e.g., v5.19), you can insert the Rust module by running:
```bash
sudo modprobe rust_minimal
```
- You can see the output from the kernel with `sudo dmesg` or `sudo vim /var/log/kern.log`.
  - Expected output:
  ```
  [  245.550047] rust_minimal: Rust minimal sample (init)
  [  245.550071] rust_minimal: Am I built-in? false
  ```
