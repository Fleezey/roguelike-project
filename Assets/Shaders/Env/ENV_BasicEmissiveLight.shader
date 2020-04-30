// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ENV/Basic Emissive Light"
{
	Properties 
	{
		[VerticalBoxStart(Albedo)]_AlbedoStart("",int) = 0
        _AlbedoMap ("Albedo Map", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		[VerticalBoxEnd]_AlbedoEnd("",int) = 0

		[VerticalBoxStart(Normal)]_NormalStart("",int) = 0
        [NoScaleOffset]_BumpMap ("Normal Map", 2D) = "white" {}
        _BumpIntensity ("Normal Intensity", Range(0.001, 10.0)) = 1.0
		[VerticalBoxEnd]_NormalEnd("",int) = 0	
		
		[VerticalBoxStart(Ambient Roughness Metallic)]_ARMStart("",int) = 0
        [NoScaleOffset]_ARMMap ("ARM Map", 2D) = "white" {} // Ambient, Roughness & Metallic
        _AmbientIntensity ("Ambient Occlusion Intensity", Range(0.0, 10.0)) = 1.0
		_Metallic ("Metallic", Range(0, 1)) = 1
		_Roughness ("Roughness", float) = 0.5
		[VerticalBoxEnd]_ARMEnd("",int) = 0

		[VerticalBoxStart(Lighting)]_LightingStart("",int) = 0
			[VerticalBoxStart(Rim Light, 2)]_RimLightStart("",int) = 0
			_RimAmount ("Rim Amount", Range(0, 1)) = 0.716
			_RimThreshold ("Rim Threshold", Range(0, 1)) = 0.1
			_RimIntensity ("Rim Intensity", float) = 1.0
			[VerticalBoxEnd]_RimLightEnd("",int) = 0
		[VerticalBoxEnd]_LightingEnd("",int) = 0

		[VerticalBoxStart(Emission)]_EmissionStart("",int) = 0
		[NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "black" {}
		_EmissionColorGain ("Emission Color Gain", float) = 1.0
		_EmissionIntensity ("Emission Intensity", float) = 1.0
		_EmissionDistance ("Emission Range", float) = 1.0
		[VerticalBoxEnd]_LightingEnd("",int) = 0
	}

	SubShader {
		Tags { "Queue"="Transparent-1" "LightMode"="Always"}

		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "UnityDeferredLibrary.cginc"

		// Light color
		half4 _CustomLightColor, _Color;
		float _Metallic;
		sampler2D _AlbedoMap, _BumpMap, _ARMMap, _EmissionMap;
		float4 _AlbedoMap_ST;
		float _BumpIntensity, _AmbientIntensity, _Roughness, _RimAmount, _RimThreshold, _RimIntensity;
		float _EmissionColorGain, _EmissionIntensity, _EmissionDistance;

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

			sampler2D _CameraGBufferTexture0;
			sampler2D _CameraGBufferTexture1;
			sampler2D _CameraGBufferTexture2;

			struct a2f
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

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
				return res * _EmissionIntensity;
			}

			v2f vert (a2f i)
			{
				v2f o;
				i.vertex += i.normal * _EmissionDistance;
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
			//Tags {"LightMode"="Deferred"}
			//Tags {"LightMode"="Always"}
			Fog { Mode Off }
			ZWrite Off
			Blend One One
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#pragma exclude_renderers nomrt
			#pragma multi_compile ___ UNITY_HDR_ON
			#pragma target 3.0

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

			struct v2f 
			{
				float4 screenPos : SV_POSITION;
				float4 worldPos : TEXCOORD0;
				float2 uv : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 normal : TEXCOORD4;
				float3 viewDir : TEXCOORD5;
			};
			
			struct p2s
			{
				half4 albedo : SV_Target0;
				half4 specular : SV_Target1;
				half4 normal : SV_Target2;
				half4 emission : SV_Target3;
			};

			v2f vert (appdata v) 
			{
				v2f vs;
				vs.screenPos = UnityObjectToClipPos( v.vertex );
				vs.worldPos = mul(unity_ObjectToWorld, v.vertex);				
				vs.normal = UnityObjectToWorldNormal(v.normal);
                vs.uv = TRANSFORM_TEX(v.uv, _AlbedoMap);
				vs.viewDir = WorldSpaceViewDir(v.vertex);

                half3 wNormal = UnityObjectToWorldNormal(v.normal);
                half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
 
                vs.tangent = wTangent;
                vs.bitangent = wBitangent;
                vs.normal = wNormal;
				return vs;
			}
			
			p2s frag (v2f vs)
			{
				p2s ps;
                half4 albedoMap = tex2D(_AlbedoMap, vs.uv);
                half4 aRMMap = tex2D(_ARMMap, vs.uv);
				half4 emissionMap = tex2D(_EmissionMap, vs.uv);
                half3 albedo = albedoMap.rgb * _Color.rgb * pow(aRMMap.r, _AmbientIntensity);
                half3 specularMap;	

				float3 normalDirection = normalize(vs.normal);
                half3 normalMap = UnpackNormal(tex2D(_BumpMap, vs.uv));
                normalMap.xy *= _BumpIntensity + _BumpIntensity;
                normalMap = normalize(normalMap);
                half3x3 tbn = half3x3(vs.tangent, vs.bitangent, vs.normal);
                half3 worldNormal = normalize(mul(normalMap, tbn));

				float3 viewDir = normalize(vs.viewDir);
				float NdotL = dot(_WorldSpaceLightPos0, normalDirection);

				// Calculate rim lighting.
				float rimDot = 1 - dot(viewDir, worldNormal);
				float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
				rimIntensity = smoothstep(1.0 - _RimAmount - 0.01, 1.0 - _RimAmount + 0.01, rimIntensity);
				float4 rim = rimIntensity * _LightColor;

				half specularMonochrome; 
				half3 diffuseColor = DiffuseAndSpecularFromMetallic(albedo, aRMMap.b * (1 - _Metallic), specularMap, specularMonochrome );
				ps.albedo = half4( diffuseColor, 1.0 );
				ps.albedo.rgb += ps.albedo * rim * max(_RimIntensity, 0.0);// * (1.0 - aRMMap.b);
				ps.albedo.rgb = saturate(ps.albedo.rgb);
				ps.albedo.a = 1.0;
				ps.specular = aRMMap.g * (1.0 - min(_Roughness, 1.0)) * half4(albedo, 1.0 );
				ps.normal = half4( worldNormal * 0.5 + 0.5, 1.0 );
				ps.emission = half4((emissionMap * _EmissionIntensity * _EmissionColorGain).rgb, _EmissionIntensity * _EmissionColorGain);
				#ifndef UNITY_HDR_ON
					ps.emission.rgb = exp2(-ps.emission.rgb/max(1, _EmissionIntensity));
				#endif
				return ps;
			}
			ENDCG
		}
	}
	Fallback Off
}
