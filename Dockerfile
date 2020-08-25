FROM ubuntu:latest


RUN apt-get update && apt-get install -y clang llvm lld python3 wget

WORKDIR /root

# Downloading the arm-none-eabi toolchain takes a long time.
# Run as a separate step so progress is cached in case of timeout
RUN wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2
RUN tar -xjf gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2 && rm gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2

# Add arm-none-eabi toolchain to the path
ENV PATH=${PATH}:/root/gcc-arm-none-eabi-9-2020-q2-update/bin