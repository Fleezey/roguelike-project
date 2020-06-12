// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ENV/Basic Vertex Paint"
{
	Properties 
	{
        // Red
        [VerticalBoxStart(Red Vertices, 1, 0.25, 0.25)]_VerticesStartR ("",int) = 0
            [VerticalBoxStart(Albedo, 1, 0.25, 0.25, 2)]_AlbedoStartR ("",int) = 0
                _AlbedoMapR ("Albedo Map", 2D) = "white" {}
                [Toggle] _worldPositionUvsR("World Position Uvs", Float) = 0
                _uvMetricR ("Uv Metric", float) = 10.0
                [HDR] _ColorR ("Color", Color) = (1,1,1,1)
            [VerticalBoxEnd]_AlbedoEndR ("",int) = 0

            [VerticalBoxStart(Normal, 1, 0.25, 0.25, 2)]_NormalStartR ("",int) = 0
                [NoScaleOffset]_BumpMapR ("Normal Map", 2D) = "white" {}
                _BumpIntensityR ("Normal Intensity", Range(0.001, 10.0)) = 1.0
            [VerticalBoxEnd]_NormalEndR ("",int) = 0	
            
            [VerticalBoxStart(Ambient Roughness Metallic Height, 1, 0.25, 0.25, 2)]_ARMStartR ("",int) = 0
                [NoScaleOffset]_ARMMapR ("ARMH Map", 2D) = "white" {} // Ambient, Roughness & Metallic
                _AmbientIntensityR ("Ambient Occlusion Intensity", Range(0.0, 10.0)) = 1.0
                _MetallicR ("Metallic", Range(0, 1)) = 1
                _RoughnessR ("Roughness", float) = 0.5
            [VerticalBoxEnd]_ARMEndR ("",int) = 0

            [VerticalBoxStart(Lighting, 1, 0.25, 0.25, 2)]_LightingStartR ("",int) = 0
                [VerticalBoxStart(Rim Light, 1, 0.25, 0.25, 3)]_RimLightStartR ("",int) = 0
                    _RimAmountR ("Rim Amount", Range(0, 1)) = 0.716
                    _RimThresholdR ("Rim Threshold", Range(0, 1)) = 0.1
                    _RimIntensityR ("Rim Intensity", float) = 1.0
                [VerticalBoxEnd]_RimLightEndR ("",int) = 0

                [VerticalBoxStart(Emission, 1, 0.25, 0.25, 3)]_EmissionStartR ("",int) = 0
                    [NoScaleOffset]_EmissionMapR ("Emission Map", 2D) = "black" {}
                    [HDR]_EmissionColorR ("Color", Color) = (1,1,1)
                    _EmissionColorGainR ("Emission Color Gain", float) = 1.0
                    _EmissionIntensityR ("Emission Intensity", float) = 1.0
                [VerticalBoxEnd]_EmissionEndR ("",int) = 0
            [VerticalBoxEnd]_LightingEndR ("",int) = 0
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
            
            [VerticalBoxStart(Ambient Roughness Metallic Height, 0.25, 1, 0.25, 2)]_ARMStartG ("",int) = 0
                [NoScaleOffset]_ARMMapG ("ARMH Map", 2D) = "white" {} // Ambient, Roughness & Metallic
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
            
            [VerticalBoxStart(Ambient Roughness Metallic Height, 0.25, 0.5, 1, 2)]_ARMStartB ("",int) = 0
                [NoScaleOffset]_ARMMapB ("ARMH Map", 2D) = "white" {} // Ambient, Roughness & Metallic
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

		ENDCG

		Pass 
		{
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

            sampler2D _AlbedoMapR, _BumpMapR, _ARMMapR, _EmissionMapR;
            float4 _AlbedoMapR_ST;
            float _worldPositionUvsR, _uvMetricR;

            float4 _ColorR, _EmissionColorR;
            float _MetallicR, _RoughnessR;
            float _BumpIntensityR, _AmbientIntensityR;
            float _RimAmountR, _RimThresholdR, _RimIntensityR;
            float _EmissionColorGainR, _EmissionIntensityR;

            sampler2D _AlbedoMapG, _BumpMapG, _ARMMapG, _EmissionMapG;
            float4 _AlbedoMapG_ST;
            float _worldPositionUvsG, _uvMetricG;

            float4 _ColorG, _EmissionColorG;
            float _MetallicG, _RoughnessG;
            float _BumpIntensityG, _AmbientIntensityG;
            float _RimAmountG, _RimThresholdG, _RimIntensityG;
            float _EmissionColorGainG, _EmissionIntensityG;

            sampler2D _AlbedoMapB, _BumpMapB, _ARMMapB, _EmissionMapB;
            float4 _AlbedoMapB_ST;
            float _worldPositionUvsB, _uvMetricB;

            float4 _ColorB, _EmissionColorB;
            float _MetallicB, _RoughnessB;
            float _BumpIntensityB, _AmbientIntensityB;
            float _RimAmountB, _RimThresholdB, _RimIntensityB;
            float _EmissionColorGainB, _EmissionIntensityB;

            float _LightMapIntensity, _LightMapShadowIntensity;

            #include "DefaultEnvVC.cginc"

			#pragma vertex vertBasic3VC
			#pragma fragment fragBasic3VC
			#pragma exclude_renderers nomrt
			#pragma multi_compile ___ UNITY_HDR_ON
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma target 3.0

			ENDCG
		}
	}
	FallBack "VertexLit"
}