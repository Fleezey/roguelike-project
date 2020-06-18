Shader "FX/Trails"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)

        [VerticalBoxStart(Mask)]_MaskStart("",int) = 0
        _MainTex ("Color Mask", 2D) = "white" {}
            [VerticalBoxStart(Mask Effect, 2)]_MaskEffectStart("",int) = 0
            _MaskSpeed ("MaskSpeed", float) = 1.0
            _MaskIntensity ("Mask X:Intensity, Y:Power, Z:Masked Intensity W:Masked Power", Vector) = (1.0, 1.0, 1.0, 1.0)
            [VerticalBoxEnd]_MaskEffectEnd("",int) = 0
        [VerticalBoxEnd]_MaskEnd("",int) = 0
        
        [VerticalBoxStart(Displacement)]_DisplacementStart("",int) = 0
        _DisplacementNorm ("Displacement Normal", float) = 1.0
        _WaveDisplacementNorm ("Wave Normal X:Height, Y:Length, Z:Speed", Vector) = (1.0, 1.0, 1.0, 0.0)
        _DisplacementBiTan ("Displacement BiTangent", float) = 1.0
        _WaveDisplacementBiTan ("Wave BiTangent X:Height, Y:Length, Z:Speed", Vector) = (1.0, 1.0, 1.0, 0.0)
        _DirectionFrom ("Direction From", Range(-0.5, 0.5)) = 0.5
        _DirectionPow ("Direction Power", Float) = 1.0
        _DirectionMult ("Direction Mult", Float) = 1.0
        _TightEnd ("Thight End", Range(0.0, 1.0)) = 0.5
        [VerticalBoxEnd]_DisplacementEnd("",int) = 0

        [VerticalBoxStart(Line)]_LineStart("",int) = 0
        _UvLight ("Length Light XY:Power ZW:Multiplier", Vector) = (1.0, 1.0, 1.0, 1.0)
        _UvAlpha ("Length Alpha XY:Power ZW:Multiplier", Vector) = (1.0, 1.0, 1.0, 1.0)
        _UvAlphaMult ("Length Alpha Multiplier", Range(0.0, 1.0)) = 1.0
        _UvAlphaFrontPow ("Length Alpha Front Power", float) = 1.0
        _UvAlphaFrontMult ("Length Alpha Front Multiplier", float) = 1.0
        [VerticalBoxEnd]_LineEnd("",int) = 0

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Blend Source", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Blend Destination", Float) = 0
    }

    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "LightMode"="Always"}
        ZWrite Off
        Blend [_SrcBlend] [_DstBlend]
        LOD 200
        Cull Off

        CGINCLUDE
        static const float PI  = 3.14159265359f;
        static const float PI2 = 6.28318530718f;
        static const float PHI = 1.61803398875f;
        static const float randomF = 0.9283017492835;

        sampler2D _MainTex;
        float4 _Color, _MainTex_ST;

        float _MaskSpeed;
        float4 _MaskIntensity;

        float4 _WaveDisplacementNorm, _WaveDisplacementBiTan;
        float _DisplacementNorm, _DisplacementBiTan, _DirectionFrom, _DirectionPow, _DirectionMult, _TightEnd;

        float4 _UvLight, _UvAlpha;
        float _UvAlphaMult, _UvAlphaFrontPow, _UvAlphaFrontMult;

        float random (float2 uv)
        {
            return frac(sin(dot(uv,float2(12.9898,78.233)))*43758.5453123);
        }

        float4 RotateAroundYInDegrees (float4 vertex, float degrees)
        {
            float alpha = degrees * PI / 180.0;
            float sina, cosa;
            sincos(alpha, sina, cosa);
            float2x2 m = float2x2(cosa, -sina, sina, cosa);
            return float4(mul(m, vertex.xz), vertex.yw).xzyw;
        }

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct a2v {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 maskUv : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.uv = v.uv; 

                // Random values
                float fedUvx = v.uv.x + 1.0 >= 7.0 ? floor(v.uv.x - 6.0) : floor(v.uv.x);
                fedUvx = fedUvx%7.0;
                float randomIn = float((pow(10.0, abs(fedUvx)) * randomF)%10.0) / 10.0;
                float randomV = random(float2(randomIn, fedUvx))%1.0;
                float3 bitangent = cross( v.normal, v.tangent.xyz ) * v.tangent.w * 0.5 + 0.5;

                // Displacement
                float4 newVertexPos = v.vertex;
                newVertexPos += float4(v.normal * _DisplacementNorm * o.uv.y * sin(_Time.y * _WaveDisplacementNorm.z + o.uv.y * _WaveDisplacementNorm.y + randomV * PI2)%PI2 + v.normal/_WaveDisplacementNorm.x * _WaveDisplacementNorm.w * o.uv.y, 0.0) * _WaveDisplacementNorm.x;
                newVertexPos += v.vertex + float4(bitangent * _DisplacementBiTan * o.uv.y * cos(_Time.y * _WaveDisplacementBiTan.z + o.uv.y * _WaveDisplacementBiTan.y + randomV * PI2)%PI2  + bitangent/_WaveDisplacementBiTan.x * _WaveDisplacementBiTan.w * o.uv.y, 0.0) * _WaveDisplacementBiTan.x;
                newVertexPos += float4(v.normal, 0.0) * pow(lerp(o.uv.y, 1.0-o.uv.y, _TightEnd), 2.0) * _WaveDisplacementNorm.x;
                newVertexPos += float4(bitangent, 0.0) * o.uv.y * _WaveDisplacementBiTan.x;
                newVertexPos = lerp(newVertexPos, RotateAroundYInDegrees(newVertexPos, _DirectionFrom), pow(o.uv.y, _DirectionPow) * _DirectionMult);
                
                o.vertex = UnityObjectToClipPos(newVertexPos);
                o.color = fedUvx/50.0;

                o.maskUv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = fixed2(abs(o.uv.x)%1.0, o.uv.y);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Initialize
                float4 col = 1.0;

                // Color
                col.rgb = _Color.rgb;
                col.rgb += frac(pow(i.uv.x, _UvLight.x)) * frac(pow(1.0 - i.uv.x, _UvLight.x)) * pow(_UvLight.z, _UvLight.x);
                col.rgb += frac(pow(1.0 - i.uv.y, _UvLight.y)) * pow(_UvLight.w, _UvLight.y);
                float mask = saturate(pow(tex2D(_MainTex,  i.maskUv + (0.0, _Time.y * _MaskSpeed)), _MaskIntensity.y) * _MaskIntensity.x * pow(i.uv.y * _MaskIntensity.z - 0.1, _MaskIntensity.w));
                col.rgb = lerp(col.rgb, _Color.rgb, mask);
                col.rgb *= 1.0 / pow(_Color.r + _Color.g + _Color.b, 0.5);

                // Alpha
                col.a = pow(1.0 - i.uv.y, _UvAlpha.y) * _UvAlpha.w;
                col.a *= pow(i.uv.x, _UvAlpha.x) * pow(1.0 - i.uv.x, _UvAlpha.x) * 2.0 * _UvAlpha.z;

                // Front Alpha
                col.a *= saturate(pow(i.uv.y, _UvAlphaFrontPow) * pow(_UvAlphaFrontMult, _UvAlphaFrontPow));
                col.a = saturate(col.a) * _UvAlphaMult;
                return saturate(col);
            }
            ENDCG
        }
    }
}
