#include <time.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <fenv.h>

#pragma STDC FENV_ACCESS ON

uint64_t add_float(uint64_t a, uint64_t b){
    union converter {
        uint64_t u;
        double d;
    };

    const int originalRounding = fegetround();
    fesetround(FE_TONEAREST);

    union converter converter1;
    union converter converter2;
    union converter result_converter;

    converter1.u = a;
    converter2.u = b;
    result_converter.d = converter1.d + converter2.d;

    fesetround(originalRounding);

    return result_converter.u;
}