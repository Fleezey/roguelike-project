#if !defined(DEFAULT_ENV_VC_INCLUDED)
#define DEFAULT_ENV_VC_INCLUDED

#include "DefaultEnv.cginc"

float heightblend(float input1, float height1, float input2, float height2)
{
    float height_start = max(height1, height2) - 0.5;// _HeightblendFactor;
    float level1 = max(height1 - height_start, 0);
    float level2 = max(height2 - height_start, 0);
    return ((input1 * level1) + (input2 * level2)) / (level1 + level2);
}

float4 heightblend(float4 input1, float height1, float4 input2, float height2)
{
    float height_start = max(height1, height2) - 0.5;// _HeightblendFactor;
    float level1 = max(height1 - height_start, 0);
    float level2 = max(height2 - height_start, 0);
    return ((input1 * level1) + (input2 * level2)) / (level1 + level2);
}

float heightlerp(float input1, float height1, float input2, float height2, float t)
{
    t = clamp(t, 0, 1);
    return heightblend(input1, height1 * (1 - t), input2, height2 * t);
}

float4 heightlerp(float4 input1, float height1, float4 input2, float height2, float t)
{
    t = clamp(t, 0, 1);
    return heightblend(input1, height1 * (1 - t), input2, height2 * t);
}

struct v2fBasicVC
{
    float4 screenPos : SV_POSITION;
    float4 worldPos : TEXCOORD0;
    float2 uvR : TEXCOORD1;
    float2 uvG : TEXCOORD2;
    float2 uvB : TEXCOORD3;
    float3 tangent : TEXCOORD4;
    float3 bitangent : TEXCOORD5;
    float3 normal : TEXCOORD6;
    float3 viewDir : TEXCOORD7;
    half2 lightmapuv : TEXCOORD8;
    float4 color : COLOR;
};

struct appdataBasicVC
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
};

v2fBasicVC vertBasic3VC (appdataBasicVC vVC) 
{
    v2fBasicVC vsVC;

    vertVars red;
    vertVars green;
    vertVars blue;

    appdataBasic v;
    v.vertex = vVC.vertex;
    v.normal = vVC.normal;
    v.tangent = vVC.tangent;
    v.uv = vVC.uv;
    v2fBasic vs = vertBasicCalc(v);

    red.albedoMap = _AlbedoMapR;
    red.albedoMap_ST = _AlbedoMapR_ST;
    red.worldPositionUvs = _worldPositionUvsR;
    red.uvMetric = _uvMetricR;
    vsVC.uvR = vertBasicCalcUV(v, red);

    green.albedoMap = _AlbedoMapG;
    green.albedoMap_ST = _AlbedoMapG_ST;
    green.worldPositionUvs = _worldPositionUvsG;
    green.uvMetric = _uvMetricG;
    vsVC.uvG = vertBasicCalcUV(v, green);

    blue.albedoMap = _AlbedoMapB;
    blue.albedoMap_ST = _AlbedoMapB_ST;
    blue.worldPositionUvs = _worldPositionUvsB;
    blue.uvMetric = _uvMetricB;
    vsVC.uvB = vertBasicCalcUV(v, blue);

    vsVC.screenPos = vs.screenPos;
    vsVC.worldPos = vs.worldPos;
    vsVC.tangent = vs.tangent;
    vsVC.bitangent = vs.bitangent;
    vsVC.normal = vs.normal;
    vsVC.viewDir = vs.viewDir;
    vsVC.lightmapuv = vs.lightmapuv;

    vsVC.color = vVC.color;

    return vsVC;
}

p2sBasic fragBasic3VC (v2fBasicVC vsVC) 
{
    p2sBasic ps;

    v2fBasic vs;
    vs.screenPos = vsVC.screenPos;
    vs.worldPos = vsVC.worldPos;
    vs.tangent = vsVC.tangent;
    vs.bitangent = vsVC.bitangent;
    vs.normal = vsVC.normal;
    vs.viewDir = vsVC.viewDir;
    vs.lightmapuv = vsVC.lightmapuv;

    fragVars red;
    fragVars green;
    fragVars blue;
    
    red.albedoMap = _AlbedoMapR;
    red.bumpMap = _BumpMapR;
    red.aRMMap = _ARMMapR;
    red.emissionMap = _EmissionMapR;
    red.color = _ColorR;
    red.emissionColor = _EmissionColorR;
    red.metallic = _MetallicR;
    red.roughness = _RoughnessR;
    red.bumpIntensity = _BumpIntensityR;
    red.ambientIntensity = _AmbientIntensityR;
    red.rimAmount = _RimAmountR;
    red.rimThreshold = _RimThresholdR;
    red.rimIntensity = _RimIntensityR;
    red.emissionColorGain = _EmissionColorGainR;
    red.emissionIntensity = _EmissionIntensityR;
    red.lightMapIntensity = _LightMapIntensity;
    red.lightMapShadowIntensity = _LightMapShadowIntensity;
    p2sBasic pR = fragBasicCalc(vs, red, vsVC.uvR);

    green.albedoMap = _AlbedoMapG;
    green.bumpMap = _BumpMapG;
    green.aRMMap = _ARMMapG;
    green.emissionMap = _EmissionMapG;
    green.color = _ColorG;
    green.emissionColor = _EmissionColorG;
    green.metallic = _MetallicG;
    green.roughness = _RoughnessG;
    green.bumpIntensity = _BumpIntensityG;
    green.ambientIntensity = _AmbientIntensityG;
    green.rimAmount = _RimAmountG;
    green.rimThreshold = _RimThresholdG;
    green.rimIntensity = _RimIntensityG;
    green.emissionColorGain = _EmissionColorGainG;
    green.emissionIntensity = _EmissionIntensityG;
    green.lightMapIntensity = _LightMapIntensity;
    green.lightMapShadowIntensity = _LightMapShadowIntensity;
    p2sBasic pG = fragBasicCalc(vs, green, vsVC.uvG);

    blue.albedoMap = _AlbedoMapB;
    blue.bumpMap = _BumpMapB;
    blue.aRMMap = _ARMMapB;
    blue.emissionMap = _EmissionMapB;
    blue.color = _ColorB;
    blue.emissionColor = _EmissionColorB;
    blue.metallic = _MetallicB;
    blue.roughness = _RoughnessB;
    blue.bumpIntensity = _BumpIntensityB;
    blue.ambientIntensity = _AmbientIntensityB;
    blue.rimAmount = _RimAmountB;
    blue.rimThreshold = _RimThresholdB;
    blue.rimIntensity = _RimIntensityB;
    blue.emissionColorGain = _EmissionColorGainB;
    blue.emissionIntensity = _EmissionIntensityB;
    blue.lightMapIntensity = _LightMapIntensity;
    blue.lightMapShadowIntensity = _LightMapShadowIntensity;
    p2sBasic pB = fragBasicCalc(vs, blue, vsVC.uvB);

    float hD = 0.0;
    float hR = pR.gBuffer0.a;
    float hG = pG.gBuffer0.a;
    float hB = pB.gBuffer0.a;
    
    // One way lerp
    ps.gBuffer0 = lerp(pB.gBuffer0, pR.gBuffer0, clamp(hR - 1.0 + vsVC.color.r * 2.0, 0.0, 1.0));
    ps.gBuffer0 = lerp(ps.gBuffer0, pG.gBuffer0, clamp(hG - 1.0 + vsVC.color.g * 2.0, 0.0, 1.0));
    ps.gBuffer0 = lerp(ps.gBuffer0, pB.gBuffer0, clamp(hB - 1.0 + vsVC.color.b * 2.0, 0.0, 1.0));

    ps.gBuffer1 = lerp(pB.gBuffer1, pR.gBuffer1, clamp(hR - 1.0 + vsVC.color.r * 2.0, 0.0, 1.0));
    ps.gBuffer1 = lerp(ps.gBuffer1, pG.gBuffer1, clamp(hG - 1.0 + vsVC.color.g * 2.0, 0.0, 1.0));
    ps.gBuffer1 = lerp(ps.gBuffer1, pB.gBuffer1, clamp(hB - 1.0 + vsVC.color.b * 2.0, 0.0, 1.0));

    ps.gBuffer2 = lerp(pB.gBuffer2, pR.gBuffer2, clamp(hR - 1.0 + vsVC.color.r * 2.0, 0.0, 1.0));
    ps.gBuffer2 = lerp(ps.gBuffer2, pG.gBuffer2, clamp(hG - 1.0 + vsVC.color.g * 2.0, 0.0, 1.0));
    ps.gBuffer2 = lerp(ps.gBuffer2, pB.gBuffer2, clamp(hB - 1.0 + vsVC.color.b * 2.0, 0.0, 1.0));

    ps.gBuffer3 = lerp(pB.gBuffer3, pR.gBuffer3, clamp(hR - 1.0 + vsVC.color.r * 2.0, 0.0, 1.0));
    ps.gBuffer3 = lerp(ps.gBuffer3, pG.gBuffer3, clamp(hG - 1.0 + vsVC.color.g * 2.0, 0.0, 1.0));
    ps.gBuffer3 = lerp(ps.gBuffer3, pB.gBuffer3, clamp(hB - 1.0 + vsVC.color.b * 2.0, 0.0, 1.0));
        
    // Two way lerp
    /*
    ps.gBuffer0 = heightlerp(pB.gBuffer0, hD, pR.gBuffer0, hR, vsVC.color.r);
    ps.gBuffer0 = heightlerp(ps.gBuffer0, hR, pG.gBuffer0, hG, vsVC.color.g);
    ps.gBuffer0 = heightlerp(ps.gBuffer0, hG, pB.gBuffer0, hB, vsVC.color.b);

    ps.gBuffer1 = heightlerp(pB.gBuffer1, hD, pR.gBuffer1, hR, vsVC.color.r);
    ps.gBuffer1 = heightlerp(ps.gBuffer1, hR, pG.gBuffer1, hG, vsVC.color.g);
    ps.gBuffer1 = heightlerp(ps.gBuffer1, hG, pB.gBuffer1, hB, vsVC.color.b);

    ps.gBuffer2 = heightlerp(pB.gBuffer2, hD, pR.gBuffer2, hR, vsVC.color.r);
    ps.gBuffer2 = heightlerp(ps.gBuffer2, hR, pG.gBuffer2, hG, vsVC.color.g);
    ps.gBuffer2 = heightlerp(ps.gBuffer2, hG, pB.gBuffer2, hB, vsVC.color.b);

    ps.gBuffer3 = heightlerp(pB.gBuffer3, hD, pR.gBuffer3, hR, vsVC.color.r);
    ps.gBuffer3 = heightlerp(ps.gBuffer3, hR, pG.gBuffer3, hG, vsVC.color.g);
    ps.gBuffer3 = heightlerp(ps.gBuffer3, hG, pB.gBuffer3, hB, vsVC.color.b);
    */

    return ps;
}

#endif