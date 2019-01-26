cmake_minimum_required(VERSION 3.7)
project(TCP)

set(CMAKE_CXX_STANDARD 14)

set(SOURCE_FILES rdt_abp.c)
add_executable(TCP ${SOURCE_FILES})

#rdt_abp.c rdt_gbn.cpp