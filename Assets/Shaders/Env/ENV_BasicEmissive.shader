Shader "ENV/Basic Emissive"
{
	Properties
	{
		[VerticalBoxStart(Albedo)]_AlbedoStart ("",int) = 0
			_AlbedoMap ("Albedo Map", 2D) = "white" {}
			[Toggle] _worldPositionUvs("World Position Uvs", Float) = 0
			_uvMetric ("Uv Metric", float) = 10.0
			[HDR] _Color ("Color", Color) = (1,1,1,1)
		[VerticalBoxEnd]_AlbedoEnd ("",int) = 0

		[VerticalBoxStart(Normal)]_NormalStart ("",int) = 0
			[NoScaleOffset]_BumpMap ("Normal Map", 2D) = "white" {}
			_BumpIntensity ("Normal Intensity", Range(0.001, 10.0)) = 1.0
		[VerticalBoxEnd]_NormalEnd ("",int) = 0	
		
		[VerticalBoxStart(Ambient Roughness Metallic Height)]_ARMStart ("",int) = 0
			[NoScaleOffset]_ARMMap ("ARMH Map", 2D) = "white" {} // Ambient, Roughness & Metallic
			_AmbientIntensity ("Ambient Occlusion Intensity", Range(0.0, 10.0)) = 1.0
			_Metallic ("Metallic", Range(0, 1)) = 1
			_Roughness ("Roughness", float) = 0.5
		[VerticalBoxEnd]_ARMEnd ("",int) = 0

		[VerticalBoxStart(Lighting)]_LightingStart ("",int) = 0
			[VerticalBoxStart(Rim Light, 2)]_RimLightStart ("",int) = 0
				_RimAmount ("Rim Amount", Range(0, 1)) = 0.2
				_RimThreshold ("Rim Threshold", Range(0, 1)) = 0.5
				_RimIntensity ("Rim Intensity", Range(0, 1)) = 0.25
			[VerticalBoxEnd]_RimLightEnd ("",int) = 0

			[VerticalBoxStart(Emission, 2)]_EmissionStart ("",int) = 0
				[NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "black" {}
				[HDR]_EmissionColor ("Color", Color) = (1,1,1)
				_EmissionColorGain ("Emission Color Gain", float) = 1.0
				_EmissionIntensity ("Emission Intensity", float) = 1.0
				_LightMapIntensity ("Light Map Itensity", float) = 1.0
				_LightMapShadowIntensity ("Light Map Shadow Intensity", float) = 1.0
			[VerticalBoxEnd]_EmissionEnd ("",int) = 0
		[VerticalBoxEnd]_LightingEnd ("",int) = 0
	}

	SubShader 
	{
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityDeferredLibrary.cginc"
		#include "AutoLight.cginc"
        #include "Lighting.cginc"

		ENDCG

		Pass 
		{
			Name "Deferred"
			Tags {"LightMode"="Deferred"}
         
			CGPROGRAM

			sampler2D _AlbedoMap, _BumpMap, _ARMMap, _EmissionMap;
			float4 _AlbedoMap_ST;
			float _worldPositionUvs, _uvMetric;

			float4 _Color, _EmissionColor;
			float _Metallic, _Roughness;
			float _BumpIntensity, _AmbientIntensity;
			float _RimAmount, _RimThreshold, _RimIntensity;
			float _EmissionColorGain, _EmissionIntensity;
			float _LightMapIntensity, _LightMapShadowIntensity;

			#include "DefaultEnv.cginc"

			#pragma vertex vertBasic
			#pragma fragment fragBasic
			#pragma exclude_renderers nomrt
			#pragma multi_compile ___ UNITY_HDR_ON
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma target 3.0

			ENDCG
		}
		
		Pass {
            Name "META"
            Tags {"LightMode"="Meta"}
            Cull Off
			
            CGPROGRAM
 
            #include"UnityStandardMeta.cginc"
 
            sampler2D _GIAlbedoTex;
            fixed4 _GIAlbedoColor;
            float4 frag_meta2 (v2f_meta i): SV_Target
            {
                // We're interested in diffuse & specular colors
                // and surface roughness to produce final albedo.
               
                FragmentCommonData data = UNITY_SETUP_BRDF_INPUT (i.uv);
                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);
                fixed4 c = tex2D (_GIAlbedoTex, i.uv);
                o.Albedo = fixed3(c.rgb * _GIAlbedoColor.rgb);
                o.Emission = Emission(i.uv.xy);
                return UnityMetaFragment(o);
            }
           
            #pragma vertex vert_meta
            #pragma fragment frag_meta2
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature ___ _DETAIL_MULX2
            ENDCG
		}
	}
	FallBack "VertexLit"
}