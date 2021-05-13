#include "common.hpp"

void ill_nok() {
    // OK: ill-formed and diagnosed by clangd

    /*
     | test.cpp: error: no matching function for call to 'DoEmplace'
     | test.cpp: note: candidate function template not viable: (...)
     |  [snip]
     */
    DoEmplace(reinterpret_cast<void *>(0xBAD), 3);
}
