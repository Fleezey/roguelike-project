#if !defined(DEFAULT_ENV_MOVE_INCLUDED)
#define DEFAULT_ENV_MOVE_INCLUDED

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"
#include "DefaultEnv.cginc"

#pragma multi_compile ___ UNITY_HDR_ON
#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

struct appdataBasicVC
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
};

v2fBasic vertBasicVCMove (appdataBasicVC v) 
{
    v2fBasic varOut;
    vertVars vars;
    appdataBasic vOut;
    vOut.vertex = v.vertex;
    vOut.normal = v.normal;
    vOut.tangent = v.tangent;
    vOut.uv = v.uv;
    
    // Move vertices
    vOut.vertex += v.color.r * lerp(_RedStartMove, _RedEndMove, _LinearMove) + v.color.g * lerp(_GreenStartMove, _GreenEndMove, _LinearMove) + v.color.b * lerp(_BlueStartMove, _BlueEndMove, _LinearMove);
    
    vars.albedoMap = _AlbedoMap;
    vars.albedoMap_ST = _AlbedoMap_ST;
    vars.worldPositionUvs = _worldPositionUvs;
    vars.uvMetric = _uvMetric;
    varOut = vertBasicCalc(vOut);
    varOut.uv = vertBasicCalcUV(vOut, vars);
    return varOut;
}

#endif