FROM ubuntu:latest


RUN apt-get update && apt-get install -y python3 wget

WORKDIR /root

# Downloading the arm-none-eabi toolchain takes a long time.
# Run as a separate step so progress is cached in case of timeout
RUN wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2
RUN tar -xjf gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2 && rm gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2
ENV PATH=${PATH}:/root/gcc-arm-none-eabi-9-2020-q2-update/bin

# Ubuntu uses LLD 10.0 which has a bug when specifying a (NOLOAD) section
# Use a newer release of Clang/LLVM to work around the issue
RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-10.0.1/clang+llvm-10.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz
RUN tar -xJf clang+llvm-10.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz -C clang-10.0.1 && rm clang+llvm-10.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz
ENV PATH=${PATH}:/root/clang-10.0.1/bin