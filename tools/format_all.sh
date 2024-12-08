find . -name "*.cpp,*.c,*cc,*cxx" -o -name "*.hpp,*h,*hxx" | xargs /opt/homebrew/opt/llvm/bin/clang-format -i

buildifier -r .
