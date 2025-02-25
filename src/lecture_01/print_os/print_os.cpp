#include <fstream>
#include <iostream>
#include <string>

int main()
{
    std::ifstream file("print_os/os_info_printout.txt");
    if (file.is_open())
    {
        std::string line;
        while (getline(file, line))
        {
            std::cout << line << std::endl;
        }
        file.close();
    }
    else
    {
        std::cerr << "Unable to open file" << std::endl;
    }
    return 0;
}
