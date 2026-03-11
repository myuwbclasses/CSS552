#define IsActive(flag) (flag & _ShaderMode)

#define DEBUG_SHOW(flag, color) {   \
    if (IsActive(flag))             \
        return color;               \
}

#define CONDITION_DEBUG(cond, flag, color) {    \
    if (cond)                                   \
        DEBUG_SHOW(flag, color)                 \
}

#define IsReflective(p) (p.a == kReflectiveCode)

int InSphere(float3 p) {
    float d = 0.99 * length(p - _TheCenter.xyz);
            // Make sure it is slightly outside
    return (d < _TheRadius);
}