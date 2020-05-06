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

		ENDCG

		Pass 
		{
			Tags {"LightMode"="Deferred"}
         
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma exclude_renderers nomrt
			#pragma multi_compile ___ UNITY_HDR_ON
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma target 3.0

			float4 _Color, _EmissionColor;
			float _Metallic;
			sampler2D _AlbedoMap, _BumpMap, _ARMMap, _EmissionMap;
			float4 _AlbedoMap_ST;
			float _BumpIntensity, _AmbientIntensity, _Roughness, _RimAmount, _RimThreshold, _RimIntensity;
			float _EmissionColorGain, _EmissionIntensity, _LightMapIntensity, _LightMapShadowIntensity, _worldPositionUvs, _uvMetric;

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
				half2 lightmapuv : TEXCOORD6;
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
				ps.albedo += ps.albedo * rim * max(_RimIntensity, 0.0) ;// * (1.0 - aRMMap.b);
				ps.albedo = saturate(ps.albedo);

				#ifndef LIGHTMAP_OFF
				fixed3 lightMap = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, vs.lightmapuv));
				ps.albedo.rgb = lerp(ps.albedo.rgb + (ps.albedo.rgb * pow(lightMap, _LightMapIntensity)), ps.albedo.rgb * pow(lightMap, _LightMapIntensity), _LightMapShadowIntensity);
				ps.albedo = saturate(ps.albedo);
				#endif
				ps.specular = aRMMap.g * (1.0 - min(_Roughness, 1.0)) * half4(albedo, 1.0 );
				ps.normal = half4( worldNormal * 0.5 + 0.5, 1.0 );
				ps.emission = half4((emissionMap * _EmissionIntensity * _EmissionColorGain).rgb, _EmissionIntensity * _EmissionColorGain) * _EmissionColor;
				#ifndef UNITY_HDR_ON
					ps.emission.rgb = exp2(-ps.emission.rgb/max(1, _EmissionIntensity));
				#endif
				return ps;
			}
			ENDCG
		}
	}
	FallBack "VertexLit"
}