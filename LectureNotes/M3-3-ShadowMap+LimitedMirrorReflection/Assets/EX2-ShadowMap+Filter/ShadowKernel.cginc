#define INSHADOW_SIZE(SIZE)                                 \
static const float w_##SIZE = 1.0/(SIZE*SIZE);              \
                                                            \
int filterOneRow_##SIZE(float d, float x, float y) {        \
    int count = 0;                                          \
    float2 uv = float2(x-(((SIZE-1)/2)*kInvWidth), y);      \
    for (int i=0; i<SIZE; i++) {                            \
        if (InShadow(d, uv))                                \
            count = count + 1;                              \
        uv.x += kInvWidth;                                  \
    }                                                       \
    return count;                                           \
}                                                           \
                                                            \
float InShadow_##SIZE(float d, float2 uv) {                 \
    int count = 0;                                          \
    uv.y = uv.y-(((SIZE-1)/2)*kInvHeight);                  \
    for (int c = 0; c<SIZE; c++) {                          \
        count += filterOneRow_##SIZE(d, uv.x, uv.y);        \
        uv.y += kInvHeight;                                 \
    }                                                       \
    return count * w_##SIZE;                                \
}