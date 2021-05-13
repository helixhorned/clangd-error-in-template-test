#include <map>

class Class {
public:
    Class(int) {}
    Class(double) {}

private:
    Class(void *) {}
};

extern std::map<char, Class> map;

template <typename... Args>
void
DoEmplace(char key, Args&&... args) {
    map.emplace(
        std::piecewise_construct,
        std::forward_as_tuple(key),
        std::forward_as_tuple(args)...);
}
