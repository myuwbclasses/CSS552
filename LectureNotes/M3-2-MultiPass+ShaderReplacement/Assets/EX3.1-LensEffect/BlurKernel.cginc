#define FILTER_SIZE(SIZE)                                   \
static const float w_##SIZE = 1.0/(SIZE*SIZE);              \
                                                            \
float4 filterOneRow_##SIZE(float x, float y) {              \
    float4 col = 0;                                         \
    float2 uv = float2(x-(((SIZE-1)/2)*_invWidth), y);      \
    for (int i=0; i<SIZE; i++) {                            \
        float4 n = tex2D(_MainTex, uv) * w_##SIZE;          \
        col += n;                                           \
        uv.x += _invWidth;                                  \
    }                                                       \
    return col;                                             \
}                                                           \
                                                            \
float4 filter_##SIZE(float2 uv) {                           \
    float4 col = 0;                                         \
    uv.y = uv.y - (((SIZE-1)/2)*_invHeight);                \
    for (int c = 0; c<SIZE; c++) {                          \
        col += filterOneRow_##SIZE(uv.x, uv.y);             \
        uv.y += _invHeight;                                 \
    }                                                       \
    return col;                                             \
}

FILTER_SIZE(15)
FILTER_SIZE(5)