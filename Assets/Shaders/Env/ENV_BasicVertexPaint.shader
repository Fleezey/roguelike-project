// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ENV/Basic Vertex Paint"
{
	Properties 
	{
        // Red
        [VerticalBoxStart(Red Vertices, 1, 0.25, 0.25)]_VerticesStartR ("",int) = 0
            [VerticalBoxStart(Albedo, 1, 0.25, 0.25, 2)]_AlbedoStart ("",int) = 0
                _AlbedoMap ("Albedo Map", 2D) = "white" {}
                [Toggle] _worldPositionUvs("World Position Uvs", Float) = 0
                _uvMetric ("Uv Metric", float) = 10.0
                [HDR] _Color ("Color", Color) = (1,1,1,1)
            [VerticalBoxEnd]_AlbedoEnd ("",int) = 0

            [VerticalBoxStart(Normal, 1, 0.25, 0.25, 2)]_NormalStart ("",int) = 0
                [NoScaleOffset]_BumpMap ("Normal Map", 2D) = "white" {}
                _BumpIntensity ("Normal Intensity", Range(0.001, 10.0)) = 1.0
            [VerticalBoxEnd]_NormalEnd ("",int) = 0	
            
            [VerticalBoxStart(Ambient Roughness Metallic, 1, 0.25, 0.25, 2)]_ARMStart ("",int) = 0
                [NoScaleOffset]_ARMMap ("ARM Map", 2D) = "white" {} // Ambient, Roughness & Metallic
                _AmbientIntensity ("Ambient Occlusion Intensity", Range(0.0, 10.0)) = 1.0
                _Metallic ("Metallic", Range(0, 1)) = 1
                _Roughness ("Roughness", float) = 0.5
            [VerticalBoxEnd]_ARMEnd ("",int) = 0

            [VerticalBoxStart(Lighting, 1, 0.25, 0.25, 2)]_LightingStart ("",int) = 0
                [VerticalBoxStart(Rim Light, 1, 0.25, 0.25, 3)]_RimLightStart ("",int) = 0
                    _RimAmount ("Rim Amount", Range(0, 1)) = 0.716
                    _RimThreshold ("Rim Threshold", Range(0, 1)) = 0.1
                    _RimIntensity ("Rim Intensity", float) = 1.0
                [VerticalBoxEnd]_RimLightEnd ("",int) = 0

                [VerticalBoxStart(Emission, 1, 0.25, 0.25, 3)]_EmissionStart ("",int) = 0
                    [NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "black" {}
                    [HDR]_EmissionColor ("Color", Color) = (1,1,1)
                    _EmissionColorGain ("Emission Color Gain", float) = 1.0
                    _EmissionIntensity ("Emission Intensity", float) = 1.0
                [VerticalBoxEnd]_EmissionEnd ("",int) = 0
            [VerticalBoxEnd]_LightingEnd ("",int) = 0
        [VerticalBoxEnd]_VerticesEndR("",int) = 0

        // Green
        [VerticalBoxStart(Red Vertices, 0.25, 1, 0.25)]_VerticesStartG ("",int) = 0
            [VerticalBoxStart(Albedo, 0.25, 1, 0.25, 2)]_AlbedoStartG ("",int) = 0
                _AlbedoMapG ("Albedo Map", 2D) = "white" {}
                [Toggle] _worldPositionUvsG("World Position Uvs", Float) = 0
                _uvMetricG ("Uv Metric", float) = 10.0
                [HDR] _ColorG ("Color", Color) = (1,1,1,1)
            [VerticalBoxEnd]_AlbedoEndG ("",int) = 0

            [VerticalBoxStart(Normal, 0.25, 1, 0.25, 2)]_NormalStartG ("",int) = 0
                [NoScaleOffset]_BumpMapG ("Normal Map", 2D) = "white" {}
                _BumpIntensityG ("Normal Intensity", Range(0.001, 10.0)) = 1.0
            [VerticalBoxEnd]_NormalEndG ("",int) = 0	
            
            [VerticalBoxStart(Ambient Roughness Metallic, 0.25, 1, 0.25, 2)]_ARMStartG ("",int) = 0
                [NoScaleOffset]_ARMMapG ("ARM Map", 2D) = "white" {} // Ambient, Roughness & Metallic
                _AmbientIntensityG ("Ambient Occlusion Intensity", Range(0.0, 10.0)) = 1.0
                _MetallicG ("Metallic", Range(0, 1)) = 1
                _RoughnessG ("Roughness", float) = 0.5
            [VerticalBoxEnd]_ARMEndG ("",int) = 0

            [VerticalBoxStart(Lighting, 0.25, 1, 0.25, 2)]_LightingStartG ("",int) = 0
                [VerticalBoxStart(Rim Light, 0.25, 1, 0.25, 3)]_RimLightStartG ("",int) = 0
                    _RimAmountG ("Rim Amount", Range(0, 1)) = 0.716
                    _RimThresholdG ("Rim Threshold", Range(0, 1)) = 0.1
                    _RimIntensityG ("Rim Intensity", float) = 1.0
                [VerticalBoxEnd]_RimLightEndG ("",int) = 0

                [VerticalBoxStart(Emission, 0.25, 1, 0.25, 3)]_EmissionStartG ("",int) = 0
                    [NoScaleOffset]_EmissionMapG ("Emission Map", 2D) = "black" {}
                    [HDR]_EmissionColorG ("Color", Color) = (1,1,1)
                    _EmissionColorGainG ("Emission Color Gain", float) = 1.0
                    _EmissionIntensityG ("Emission Intensity", float) = 1.0
                [VerticalBoxEnd]_EmissionEndG ("",int) = 0
            [VerticalBoxEnd]_LightingEndG ("",int) = 0
        [VerticalBoxEnd]_VerticesEndG ("",int) = 0

        // Blue
        [VerticalBoxStart(Blue Vertices, 0.25, 0.5, 1)]_VerticesStartB ("",int) = 0
            [VerticalBoxStart(Albedo, 0.25, 0.5, 1, 2)]_AlbedoStartB ("",int) = 0
                _AlbedoMapB ("Albedo Map", 2D) = "white" {}
                [Toggle] _worldPositionUvsB("World Position Uvs", Float) = 0
                _uvMetricB ("Uv Metric", float) = 10.0
                [HDR] _ColorB ("Color", Color) = (1,1,1,1)
            [VerticalBoxEnd]_AlbedoEndB ("",int) = 0

            [VerticalBoxStart(Normal, 0.25, 0.5, 1, 2)]_NormalStartB ("",int) = 0
                [NoScaleOffset]_BumpMapB ("Normal Map", 2D) = "white" {}
                _BumpIntensityB ("Normal Intensity", Range(0.001, 10.0)) = 1.0
            [VerticalBoxEnd]_NormalEndB ("",int) = 0	
            
            [VerticalBoxStart(Ambient Roughness Metallic, 0.25, 0.5, 1, 2)]_ARMStartB ("",int) = 0
                [NoScaleOffset]_ARMMapB ("ARM Map", 2D) = "white" {} // Ambient, Roughness & Metallic
                _AmbientIntensityB ("Ambient Occlusion Intensity", Range(0.0, 10.0)) = 1.0
                _MetallicB ("Metallic", Range(0, 1)) = 1
                _RoughnessB ("Roughness", float) = 0.5
            [VerticalBoxEnd]_ARMEnd ("",int) = 0

            [VerticalBoxStart(Lighting, 0.25, 0.5, 1, 2)]_LightingStartB ("",int) = 0
                [VerticalBoxStart(Rim Light, 0.25, 0.5, 1, 3)]_RimLightStartB ("",int) = 0
                    _RimAmountB ("Rim Amount", Range(0, 1)) = 0.716
                    _RimThresholdB ("Rim Threshold", Range(0, 1)) = 0.1
                    _RimIntensityB ("Rim Intensity", float) = 1.0
                [VerticalBoxEnd]_RimLightEndB ("",int) = 0

                [VerticalBoxStart(Emission, 0.25, 0.5, 1, 3)]_EmissionStartB ("",int) = 0
                    [NoScaleOffset]_EmissionMapB ("Emission Map", 2D) = "black" {}
                    [HDR]_EmissionColorB ("Color", Color) = (1,1,1)
                    _EmissionColorGainB ("Emission Color Gain", float) = 1.0
                    _EmissionIntensityB ("Emission Intensity", float) = 1.0
                [VerticalBoxEnd]_EmissionEndB ("",int) = 0
            [VerticalBoxEnd]_LightingEndB ("",int) = 0
        [VerticalBoxEnd]_VerticesEndB ("",int) = 0

		_LightMapIntensity ("Lightmap Intensity", Range(0, 10)) = 1.0
		_LightMapShadowIntensity ("Lightmap Shadow Intensity", Range(0, 1)) = 1.0
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