Shader "FX/Fire"
{
    Properties {
        _Color ("Main Color", Color) = (1,1,1,1)
        _FireMask ("Fire Texture", 2D) = "white" {}
        _FireWidth ("Fire Width", float) = 1.0
        _FireHeight ("Fire Height", float) = 1.0
        _FireXPosition ("Fire X Position", float) = 0.0
        _FireYPosition ("Fire Y Position", float) = 0.0
    }

    SubShader {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                #pragma multi_compile_fog

                #include "UnityCG.cginc"

                struct appdata_t {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                    float2 textureUv : TEXCOORD1;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                struct v2f {
                    float4 vertex : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    float2 textureUv : TEXCOORD1;
                    UNITY_FOG_COORDS(0)
                    UNITY_VERTEX_OUTPUT_STEREO
                };

                fixed4 _Color;
                sampler2D _FireMask;
                fixed4 _FireMask_ST;
                fixed _FireWidth, _FireHeight, _FireXPosition, _FireYPosition;

                v2f vert (appdata_t v)
                {
                    v2f o;
                    UNITY_SETUP_INSTANCE_ID(v);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    o.textureUv = TRANSFORM_TEX(v.textureUv, _FireMask);
                    UNITY_TRANSFER_FOG(o,o.vertex);
                    return o;
                }

                fixed4 frag (v2f i) : COLOR
                {
                    fixed4 multMask = tex2D(_FireMask, i.textureUv);
                    float x = (i.uv.x - _FireXPosition) * 1.0f/_FireWidth + _FireXPosition;
                    float y = (i.uv.y - _FireYPosition) * 1.0f/_FireHeight + _FireYPosition;
                    fixed4 col = fixed4(0.0f, 0.0f, 0.0f, 0.0f);
                    col += saturate(1.0f - sqrt(pow((_FireXPosition - x), 2.0f) + pow((_FireYPosition - y), 2.0f)));
                    col *= multMask;
                    col *= _Color;
                    UNITY_APPLY_FOG(i.fogCoord, col);
                    UNITY_OPAQUE_ALPHA(col.a);
                    return col;
                }
            ENDCG
        }
    }
}