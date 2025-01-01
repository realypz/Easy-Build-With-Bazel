find . \( -name "*.cpp" -o -name "*.c" -o -name "*.cc" -o -name "*.cxx" -o -name "*.hpp" -o -name "*.h" -o -name "*.hxx" \) | xargs /opt/homebrew/opt/llvm/bin/clang-format -i

buildifier -r .