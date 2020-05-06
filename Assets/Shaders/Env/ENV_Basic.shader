// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ENV/Basic"
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
		
		[VerticalBoxStart(Ambient Roughness Metallic)]_ARMStart ("",int) = 0
			[NoScaleOffset]_ARMMap ("ARM Map", 2D) = "white" {} // Ambient, Roughness & Metallic
			_AmbientIntensity ("Ambient Occlusion Intensity", Range(0.0, 10.0)) = 1.0
			_Metallic ("Metallic", Range(0, 1)) = 1
			_Roughness ("Roughness", float) = 0.5
		[VerticalBoxEnd]_ARMEnd ("",int) = 0

		[VerticalBoxStart(Lighting)]_LightingStart ("",int) = 0
			[VerticalBoxStart(Rim Light, 2)]_RimLightStart ("",int) = 0
				_RimAmount ("Rim Amount", Range(0, 1)) = 0.716
				_RimThreshold ("Rim Threshold", Range(0, 1)) = 0.1
				_RimIntensity ("Rim Intensity", float) = 1.0
			[VerticalBoxEnd]_RimLightEnd ("",int) = 0

			[VerticalBoxStart(Emission, 2)]_EmissionStart ("",int) = 0
				[NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "black" {}
				[HDR]_EmissionColor ("Color", Color) = (1,1,1)
				_EmissionColorGain ("Emission Color Gain", float) = 1.0
				_EmissionIntensity ("Emission Intensity", float) = 1.0
			[VerticalBoxEnd]_EmissionEnd ("",int) = 0

			_LightMapIntensity ("Lightmap Intensity", Range(0, 10)) = 1.0
			_LightMapShadowIntensity ("Lightmap Shadow Intensity", Range(0, 1)) = 1.0
		[VerticalBoxEnd]_LightingEnd ("",int) = 0
	}
	
	SubShader 
	{
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "UnityDeferredLibrary.cginc"
		#include "AutoLight.cginc"
        #include "Lighting.cginc"

		sampler2D _AlbedoMap, _BumpMap, _ARMMap, _EmissionMap;
		float4 _Color, _EmissionColor;
		float _Metallic, _Roughness;
		float4 _AlbedoMap_ST;
		float _BumpIntensity, _AmbientIntensity;
		float _RimAmount, _RimThreshold, _RimIntensity;
		float _EmissionColorGain, _EmissionIntensity;
		float _LightMapIntensity, _LightMapShadowIntensity;
		float _worldPositionUvs, _uvMetric;

		ENDCG

		Pass 
		{
			Tags {"LightMode"="Deferred"}
         
			CGPROGRAM
			#include "DefaultEnv.cginc"
			#pragma vertex vertBasic
			#pragma fragment fragBasic
			#pragma exclude_renderers nomrt
			#pragma multi_compile ___ UNITY_HDR_ON
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma target 3.0

			ENDCG
		}
	}
	FallBack "CustomDeferredShading"
}