#if !defined(DEFAULT_ENV_INCLUDED)
#define DEFAULT_ENV_INCLUDED

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

#pragma multi_compile ___ UNITY_HDR_ON
#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

sampler2D _AlbedoMap, _BumpMap, _ARMMap, _EmissionMap;
float4 _AlbedoMap_ST;
float _worldPositionUvs, _uvMetric;

float4 _Color, _EmissionColor;
float _Metallic, _Roughness;
float _BumpIntensity, _AmbientIntensity;
float _RimAmount, _RimThreshold, _RimIntensity;
float _EmissionColorGain, _EmissionIntensity;
float _LightMapIntensity, _LightMapShadowIntensity;

struct appdataBasic
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv : TEXCOORD0;
};

struct v2fBasic 
{
    float4 screenPos : SV_POSITION;
    float4 worldPos : TEXCOORD0;
    float2 uv : TEXCOORD1;
    float3 tangent : TEXCOORD2;
    float3 bitangent : TEXCOORD3;
    float3 normal : TEXCOORD4;
    float3 viewDir : TEXCOORD5;
    half2 lightmapuv : TEXCOORD6;
};

struct p2sBasic
{
    half4 gBuffer0 : SV_Target0;
    half4 gBuffer1 : SV_Target1;
    half4 gBuffer2 : SV_Target2;
    half4 gBuffer3 : SV_Target3;
};

float3 BoxProjection (
	float3 direction, float3 position,
	float4 cubemapPosition, float3 boxMin, float3 boxMax
) {
	#if UNITY_SPECCUBE_BOX_PROJECTION
		UNITY_BRANCH
		if (cubemapPosition.w > 0) {
			float3 factors =
				((direction > 0 ? boxMax : boxMin) - position) / direction;
			float scalar = min(min(factors.x, factors.y), factors.z);
			direction = direction * scalar + (position - cubemapPosition);
		}
	#endif
	return direction;
}

UnityLight CreateLight () {
	UnityLight light;
    light.dir = float3(0, 1, 0);
    light.color = 0;
	return light;
}

UnityIndirect CreateIndirectLight (v2fBasic i, float3 viewDir, float3 normal, float ambient, float roughness, float metallic) {
	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

    #if defined(LIGHTMAP_ON)
        indirectLight.diffuse = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightmapuv));
        
        #if defined(DIRLIGHTMAP_COMBINED)
            float4 lightmapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, i.lightmapuv);
            indirectLight.diffuse = DecodeDirectionalLightmap(indirectLight.diffuse, lightmapDirection, normal);
        #endif
    #else
        indirectLight.diffuse += max(0, ShadeSH9(float4(normal, 1)));
    #endif

    indirectLight.diffuse = pow(indirectLight.diffuse, _LightMapIntensity) * _LightMapShadowIntensity;

    float3 reflectionDir = reflect(-viewDir, normal);
    Unity_GlossyEnvironmentData envData;
    envData.roughness = 1 - roughness;
    envData.reflUVW = BoxProjection(
        reflectionDir, i.worldPos.xyz,
        unity_SpecCube0_ProbePosition,
        unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax
    );
    float3 probe0 = Unity_GlossyEnvironment(
        UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData
    );
    envData.reflUVW = BoxProjection(
        reflectionDir, i.worldPos.xyz,
        unity_SpecCube1_ProbePosition,
        unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax
    );
    #if UNITY_SPECCUBE_BLENDING
        float interpolator = unity_SpecCube0_BoxMin.w;
        UNITY_BRANCH
        if (interpolator < 0.99999) {
            float3 probe1 = Unity_GlossyEnvironment(
                UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0),
                unity_SpecCube0_HDR, envData
            );
            indirectLight.specular = lerp(probe1, probe0, interpolator);
        }
        else {
            indirectLight.specular = probe0;
        }
    #else
        indirectLight.specular = probe0;
    #endif

    float occlusion = ambient;
    indirectLight.diffuse *= occlusion;
    indirectLight.specular *= occlusion;

    #if UNITY_ENABLE_REFLECTION_BUFFERS
        indirectLight.specular = 0;
    #endif

	return indirectLight;
}

v2fBasic vertBasic (appdataBasic v) 
{
    v2fBasic vs;
    float3 n = normalize(mul(unity_ObjectToWorld, v.normal).xyz);
    float3 vDirection = float3(0, 0, 1);
    if(abs(n.y) < 1.0f) {
        vDirection = normalize(float3(0, 1, 0) - n.y * n);
    }
    float3 uDirection = normalize(cross(n, vDirection));
    float3 worldSpace = mul(unity_ObjectToWorld, v.vertex).xyz;

    vs.screenPos = UnityObjectToClipPos( v.vertex );
    vs.worldPos = mul(unity_ObjectToWorld, v.vertex);				
    vs.normal = UnityObjectToWorldNormal(v.normal);

    // World Position Uvs
    if(_worldPositionUvs > 0.5){
        float3 n = normalize(mul(unity_ObjectToWorld, v.normal).xyz);
        float3 vDirection = float3(0, 0, 1);
        if(abs(n.y) < 1.0f) {
            vDirection = normalize(float3(0, 1, 0) - n.y * n);
        }
        float3 uDirection = normalize(cross(n, vDirection));
        vs.uv = float2(dot(worldSpace, uDirection), dot(worldSpace, vDirection)) / _uvMetric;
        vs.uv *= _AlbedoMap_ST.xy + _AlbedoMap_ST.zw;
    }
    // Normal Uvs
    else{
        vs.uv = TRANSFORM_TEX(v.uv, _AlbedoMap);
    }
    vs.viewDir = WorldSpaceViewDir(v.vertex);

    half3 wNormal = UnityObjectToWorldNormal(v.normal);
    half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
    half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
    half3 wBitangent = cross(wNormal, wTangent) * tangentSign;

    vs.tangent = wTangent;
    vs.bitangent = wBitangent;
    vs.normal = wNormal;
    vs.lightmapuv = v.uv.xy * unity_LightmapST.xy + unity_LightmapST.zw;
    return vs;
}

p2sBasic fragBasic (v2fBasic vs)
{
    p2sBasic ps;
    half4 albedoMap = tex2D(_AlbedoMap, vs.uv);
    half4 aRMMap = tex2D(_ARMMap, vs.uv);
    half4 emissionMap = tex2D(_EmissionMap, vs.uv);
    float occlusion = lerp(1, aRMMap.r, _AmbientIntensity);
    float3 albedoColor = albedoMap * _Color.rgb;
    float metallic = lerp(0.0, 1.0, aRMMap.b * _Metallic);
    half3 specularMap;
    float alpha = albedoMap.a * _Color.a;
    float roughness = aRMMap.g * (2.0 - _Roughness);
    float3 emission = emissionMap.rgb * _EmissionIntensity * _EmissionColorGain * _EmissionColor.rgb * _EmissionColor.a;

    // Calculate albedo and spec
    float3 specularTint;
	float oneMinusReflectivity;
	float3 albedo = DiffuseAndSpecularFromMetallic(albedoColor, metallic, specularTint, oneMinusReflectivity);	
    
    // Calculate normals
    float3 normalDirection = normalize(vs.normal);
    half3 normalMap = UnpackNormal(tex2D(_BumpMap, vs.uv));
    normalMap.xy *= _BumpIntensity + _BumpIntensity;
    normalMap = normalize(normalMap);
    half3x3 tbn = half3x3(vs.tangent, vs.bitangent, vs.normal);
    half3 worldNormal = normalize(mul(normalMap, tbn));

    float3 viewDir = normalize(vs.viewDir);
    float NdotL = dot(_WorldSpaceLightPos0, normalDirection);

    // Calculate rim lighting.
    float rimDot = 1.0 - dot(worldNormal    , viewDir);
    float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
    rimIntensity = smoothstep(1.0 - _RimAmount - 0.01, 1.0 - _RimAmount + 0.01, rimIntensity);
    float4 rim = rimIntensity * _LightColor;

    float4 color = UNITY_BRDF_PBS(albedo, specularTint, oneMinusReflectivity, roughness, worldNormal, viewDir,
		CreateLight(), CreateIndirectLight(vs, viewDir, worldNormal, occlusion, roughness, metallic)
	);

    ps.gBuffer0 = float4(lerp(albedo, albedo + rimIntensity, _RimIntensity), occlusion);
    ps.gBuffer1 = float4(lerp(specularTint, specularTint * metallic, metallic), min(max(0.001, roughness) + rimIntensity * _RimIntensity, 1.0));
    ps.gBuffer2 = half4( worldNormal * 0.5 + 0.5, 1.0 );
    ps.gBuffer3 = color + float4(emission, 1.0);
    #ifndef UNITY_HDR_ON
        ps.gBuffer3.rgb = exp2(-ps.gBuffer3.rgb/max(1, _EmissionIntensity));
    #endif
    return ps;
}

#endif