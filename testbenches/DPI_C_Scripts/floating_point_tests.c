#include <time.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <math.h>
#include <fenv.h>

#pragma STDC FENV_ACCESS ON

uint64_t add_double(uint64_t a, uint64_t b){
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

uint64_t sub_double(uint64_t a, uint64_t b){
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
    result_converter.d = converter1.d - converter2.d;

    fesetround(originalRounding);

    return result_converter.u;
}

uint64_t less_double(uint64_t a, uint64_t b){
    uint64_t result;
    union converter {
        uint64_t u;
        double d;
    };

    const int originalRounding = fegetround();
    fesetround(FE_TONEAREST);

    union converter converter1;
    union converter converter2;

    converter1.u = a;
    converter2.u = b;
    result = converter1.d < converter2.d;

    fesetround(originalRounding);

    return result;
}

uint64_t equal_double(uint64_t a, uint64_t b){
    uint64_t result;
    union converter {
        uint64_t u;
        double d;
    };

    const int originalRounding = fegetround();
    fesetround(FE_TONEAREST);

    union converter converter1;
    union converter converter2;

    converter1.u = a;
    converter2.u = b;
    result = converter1.d == converter2.d;

    fesetround(originalRounding);

    return result;
}

uint64_t greater_double(uint64_t a, uint64_t b){
    uint64_t result;
    union converter {
        uint64_t u;
        double d;
    };

    const int originalRounding = fegetround();
    fesetround(FE_TONEAREST);

    union converter converter1;
    union converter converter2;

    converter1.u = a;
    converter2.u = b;
    result = converter1.d > converter2.d;

    fesetround(originalRounding);

    return result;
}

uint64_t unordered_double(uint64_t a, uint64_t b){
    uint64_t result;
    union converter {
        uint64_t u;
        double d;
    };

    const int originalRounding = fegetround();
    fesetround(FE_TONEAREST);

    union converter converter1;
    union converter converter2;

    converter1.u = a;
    converter2.u = b;
    result = isnan(converter1.d) || isnan(converter2.d);

    fesetround(originalRounding);

    return result;
}


uint32_t less_float(uint32_t a, uint32_t b){
    uint32_t result;
    union converter {
        uint32_t u;
        float f;
    };

    const int originalRounding = fegetround();
    fesetround(FE_TONEAREST);

    union converter converter1;
    union converter converter2;

    converter1.u = a;
    converter2.u = b;
    result = converter1.f < converter2.f;

    fesetround(originalRounding);

    return result;
}

uint32_t greater_float(uint32_t a, uint32_t b){
    uint32_t result;
    union converter {
        uint32_t u;
        float f;
    };

    const int originalRounding = fegetround();
    fesetround(FE_TONEAREST);

    union converter converter1;
    union converter converter2;

    converter1.u = a;
    converter2.u = b;
    result = converter1.f > converter2.f;

    fesetround(originalRounding);

    return result;
}

uint32_t equal_float(uint32_t a, uint32_t b){
    uint32_t result;
    union converter {
        uint32_t u;
        float f;
    };

    const int originalRounding = fegetround();
    fesetround(FE_TONEAREST);

    union converter converter1;
    union converter converter2;

    converter1.u = a;
    converter2.u = b;
    result = converter1.f == converter2.f;

    fesetround(originalRounding);

    return result;
}

uint32_t unordered_float(uint32_t a, uint32_t b){
    uint32_t result;
    union converter {
        uint32_t u;
        float f;
    };

    const int originalRounding = fegetround();
    fesetround(FE_TONEAREST);

    union converter converter1;
    union converter converter2;

    converter1.u = a;
    converter2.u = b;
    result = isnan(converter1.f) || isnan(converter2.f);

    fesetround(originalRounding);

    return result;
}