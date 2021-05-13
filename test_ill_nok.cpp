#include "common.hpp"

void ill_nok() {
    // FIXME: ill-formed but not diagnosed by clangd

    /*
     | In file included from ./test.cpp:1:
     | In file included from (...)/include/c++/10/map:60:
     |  [snip]
 lib | .../new_allocator.h: error: no matching constructor for initialization of 'std::pair<const char, Class>'
     | .../alloc_traits.h: note: in instantiation of function template specialization ...
     |  [snip]
user | ./test.cpp: note: in instantiation of function template specialization 'std::map<char, Class>::emplace ...' ...
user | ./test.cpp: note: in instantiation of function template specialization 'DoEmplace<int, int>' requested here
     | .../stl_pair.h: note: candidate template ignored: ...
     |  [snip]
    */
    DoEmplace('d', 4, 0xBAD);  // too many arguments to any 'Class' ctor

    /*
     | In file included from ./test.cpp:1:
     | In file included from (...)/include/c++/10/map:61:
     |  [snip]
 lib | .../tuple: error: field of type 'Class' has private constructor
     | .../tuple: note: in instantiation of function template specialization '(...)' requested here
     |  [snip]
user | ./test.cpp: note: in instantiation of function template specialization 'std::map<char, Class>::emplace ...' ...
user | ./test.cpp: note: in instantiation of function template specialization 'DoEmplace<void *>' requested here
user | ./test.cpp: note: declared private here
     */
    DoEmplace('e', reinterpret_cast<void *>(0xBAD));  // private ctor
}
