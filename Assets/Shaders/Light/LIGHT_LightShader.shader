﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_CameraToWorld' with 'unity_CameraToWorld'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "LIGHT/PointArea" {
	Properties 
	{
		[VerticalBoxStart(Emission)]_EmissionStart("",int) = 0
		[NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "white" {}
		_EmissionIntensity ("Emission Intensity", float) = 1.0
		[HDR]_EmissionColor ("Emission Color", Color) = (1,1,1,1)
		_LightDistance ("Distance", float) = 1.0
		[VerticalBoxEnd]_LightingEnd("",int) = 0
	}
	SubShader {
		Tags { "Queue"="Transparent-1" }

		CGINCLUDE
		#define POINT
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "UnityDeferredLibrary.cginc"

		// Light color
		half4 _CustomLightColor;
		sampler2D _EmissionMap;
		float _LightDistance, _EmissionIntensity;

		// Light parameters
		// x tube length
		// y size
		// z 1/radius
		// w kind
		float4 _CustomLightParams;
		#define _CustomLightLength _CustomLightParams.x
		#define _CustomLightSize _CustomLightParams.y
		#define _CustomLightInvSqRadius _CustomLightParams.z
		#define _CustomLightKind _CustomLightParams.w


		sampler2D _CameraGBufferTexture0;
		sampler2D _CameraGBufferTexture1;
		sampler2D _CameraGBufferTexture2;

		struct v2f
		{
			float4 pos : SV_POSITION;
			float4 uv : TEXCOORD0;
			float3 ray : TEXCOORD1;
			float2 screenUV : TEXCOORD2;
			half3 orientation : TEXCOORD3;
		};

		half3 CalcSphereLightToLight(float3 pos, float3 lightPos, float3 eyeVec, half3 normal, float sphereRad)
		{
			half3 viewDir = -eyeVec;
			half3 r = reflect (viewDir, normal);

			float3 L = lightPos - pos;
			float3 centerToRay	= dot (L, r) * r - L;
			float3 closestPoint	= L + centerToRay * saturate(sphereRad / length(centerToRay));
			return normalize(closestPoint);
		}


		half3 CalcTubeLightToLight(float3 pos, float3 tubeStart, float3 tubeEnd, float3 eyeVec, half3 normal, float tubeRad)
		{
			half3 N = normal;
			half3 viewDir = -eyeVec;
			half3 r = reflect (viewDir, normal);

			float3 L0		= tubeStart - pos;
			float3 L1		= tubeEnd - pos;
			float distL0	= length( L0 );
			float distL1	= length( L1 );
			
			float NoL0		= dot( L0, N ) / ( 2.0 * distL0 );
			float NoL1		= dot( L1, N ) / ( 2.0 * distL1 );
			float NoL		= ( 2.0 * clamp( NoL0 + NoL1, 0.0, 1.0 ) ) 
							/ ( distL0 * distL1 + dot( L0, L1 ) + 2.0 );
			
			float3 Ld			= L1 - L0;
			float RoL0		= dot( r, L0 );
			float RoLd		= dot( r, Ld );
			float L0oLd 	= dot( L0, Ld );
			float distLd	= length( Ld );
			float t			= ( RoL0 * RoLd - L0oLd ) / ( distLd * distLd - RoLd * RoLd );
			
			float3 closestPoint	= L0 + Ld * clamp( t, 0.0, 1.0 );
			float3 centerToRay	= dot( closestPoint, r ) * r - closestPoint;
			closestPoint		= closestPoint + centerToRay * clamp( tubeRad / length( centerToRay ), 0.0, 1.0 );
			float3 l				= normalize( closestPoint );
			return l;
		}


		void DeferredCalculateLightParams (
			v2f i,
			out float3 outWorldPos,
			out float2 outUV,
			out half3 outLightDir,
			out float outAtten,
			out float outFadeDist)
		{
			i.ray = i.ray * (_ProjectionParams.z / i.ray.z);
			float2 uv = i.uv.xy / i.uv.w;
			
			// read depth and reconstruct world position
			float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
			depth = Linear01Depth (depth);
			float4 vpos = float4(i.ray * depth,1);
			float3 wpos = mul (unity_CameraToWorld, vpos).xyz;
			
			float3 lightPos = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]);

			// Point light
			float3 tolight = wpos - lightPos;
			half3 lightDir = -normalize (tolight);
			
			float att = dot(tolight, tolight) * _CustomLightInvSqRadius;
			float atten = tex2D (_LightTextureB0, att.rr).UNITY_ATTEN_CHANNEL;

			outWorldPos = wpos;
			outUV = uv;
			outLightDir = lightDir;
			outAtten = atten;
			outFadeDist = 0;
		}

		half4 CalculateLight (v2f i)
		{
			float3 wpos;
			float2 uv;
			float atten, fadeDist;
			UnityLight light = (UnityLight)0;
			DeferredCalculateLightParams (i, wpos, uv, light.dir, atten, fadeDist);

			half4 gbuffer0 = tex2D (_CameraGBufferTexture0, uv);
			half4 gbuffer1 = tex2D (_CameraGBufferTexture1, uv);
			half4 gbuffer2 = tex2D (_CameraGBufferTexture2, uv);

			light.color = _CustomLightColor.rgb * atten;
			half3 baseColor = gbuffer0.rgb;
			half3 specColor = gbuffer1.rgb;
			half3 normalWorld = gbuffer2.rgb * 2 - 1;
			normalWorld = normalize(normalWorld);
			half oneMinusRoughness = gbuffer1.a;
			float3 eyeVec = normalize(wpos-_WorldSpaceCameraPos);

			// Sphere light
			float3 lightPos = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]);
			float3 lightAxisX = normalize(float3(unity_ObjectToWorld[0][0], unity_ObjectToWorld[1][0], unity_ObjectToWorld[2][0]));
			if (_CustomLightKind == 1)
			{
				float3 lightPos1 = lightPos + lightAxisX * _CustomLightLength;
				float3 lightPos2 = lightPos - lightAxisX * _CustomLightLength;
				light.dir = CalcTubeLightToLight (wpos, lightPos1, lightPos2, eyeVec, normalWorld, _CustomLightSize);
			}
			else
			{
				light.dir = CalcSphereLightToLight (wpos, lightPos, eyeVec, normalWorld, _CustomLightSize);
			}

			half oneMinusReflectivity = 1 - SpecularStrength(specColor.rgb);
			light.ndotl = LambertTerm (normalWorld, light.dir);
			
			UnityIndirect ind;
			UNITY_INITIALIZE_OUTPUT(UnityIndirect, ind);
			ind.diffuse = 0;
			ind.specular = 0;

			half4 res = UNITY_BRDF_PBS (baseColor, specColor, oneMinusReflectivity, oneMinusRoughness, normalWorld, -eyeVec, light, ind);
			//if (_CustomLightKind == 1)
			//	res.x = 1;
			return res * _EmissionIntensity;

			//half4 emission = tex2D(_EmissionMap, i.uv);
			//emission.rgb *= (1 - baseColor);
			
			//return res * emission * 10.0;// * emission;
		}
		ENDCG

		Pass {
			Fog { Mode Off }
			ZWrite Off
			ZTest Always
			Blend One One
			Cull Front
			Offset -5000, -5000
			
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma exclude_renderers nomrt

			struct a2f
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

			v2f vert (a2f i)
			{
				v2f o;
				i.vertex += i.normal * _LightDistance;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.screenUV = i.vertex.xz+0.5;
				o.uv = ComputeScreenPos (o.pos);
				o.ray = mul (UNITY_MATRIX_MV, i.vertex).xyz * float3(-1,-1,1);
				o.orientation = mul ((float3x3)unity_ObjectToWorld, float3(0,1,0));
				return o;
			}


			half4 frag (v2f i) : SV_Target
			{
				return CalculateLight(i);
			}

			ENDCG
		}

		// Light Visual pass
		Pass {
			Fog { Mode Off }
			ZWrite Off
			Blend One One

			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma exclude_renderers nomrt

			float4 vert (float4 vertex : POSITION) : SV_POSITION
			{
				return UnityObjectToClipPos(vertex);
			}

			half4 frag () : SV_Target
			{
				return half4(_CustomLightColor.rgb, 1);
			}
			ENDCG
		}

	}
	Fallback Off
}
