#ifndef MY_LIGHTS
#define MY_LIGHTS

// In the editor: one and only one instance of
//      LightLoader script should be running

static const int kNumLights = 4;

float LightState[kNumLights];  // 0 - off, 1 - Direction, 2 - Point, 3 - Spot


#endif // MY_LIGHTS