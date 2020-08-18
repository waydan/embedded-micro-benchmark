FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y clang lldb lld python3 git
RUN apt-get install -y gcc-arm-none-eabi
RUN apt-get install -y python3-pip
RUN pip install pygdbmi