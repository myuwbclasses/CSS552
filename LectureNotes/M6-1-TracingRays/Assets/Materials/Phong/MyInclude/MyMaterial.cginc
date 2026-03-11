#ifndef MY_MATERIAL
#define MY_MATERIAL

// In the editor: 
//      LoadMaterial script should be on each object if want to override the global values
float4 _Ka, _Kd, _Ks;
float _Specularity;
float _Reflectivity;

// The following is Global to shader to support ray tracing demo
// This is a hack: Hardcode
//    Sphere is ID=0
//    Triangle is ID=1
float4 _RTKa[2], _RTKd[2], _RTKs[2];
float _RTSpecularity[2];
float _RTReflectivity[2];

#endif // MY_MATERIAL