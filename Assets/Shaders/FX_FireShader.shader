Shader "FX/Fire"
{
    Properties {
        _Color ("Main Color", Color) = (1,1,1,1)
        [VerticalBoxStart(Fire Shape)]_FireShapeStart("",int) = 0
        _FireWidth ("Fire Width", float) = 1.0
        _FireHeight ("Fire Height", float) = 1.0
        _FireXPosition ("Fire X Position", float) = 0.0
        _FireYPosition ("Fire Y Position", float) = 0.0
        _FireScale ("Fire Scale", Vector) = (1.0, 1.0, 1.0, 1.0)
            [VerticalBoxStart(Fire Shape Move, 2)]_FireShapeMoveStart("", int) = 0
            _FireWiggle ("Fire Wiggle", Vector) = (0.0, 0.0, 0.0, 0.0)
            _FireWiggleSpeed ("Fire Wiggle Speed", Vector) = (1.0, 1.0, 1.0, 1.0)
            [VerticalBoxEnd]_FireShapeMoveEnd("", int) = 0
		[VerticalBoxEnd]_FireShapeEnd("",int) = 0

        [VerticalBoxStart(Fire Mask)]_FireMaskStart("",int) = 0
        _FireMask ("Fire Texture", 2D) = "white" {}
        _FireMaskPow ("Fire Mask Pow", float) = 1.0
            [VerticalBoxStart(Fire Mask Main, 2)]_FireMaskMainStart("",int) = 0
            _FireMaskMainSize ("Fire Mask Main Size", float) = 1.0
            _FireMaskMainSpeed ("Fire Mask Main Speed", float) = 1.0
            [VerticalBoxEnd]_FireMaskMainEnd("",int) = 0
            [VerticalBoxStart(Fire Sub Mask, 2)]_FireMaskSubStart("",int) = 0
            _FireMaskSubSize ("Fore Mask Sub Size", float) = 1.0
            _FireMaskSubSpeed ("Fore Mask Sub Speed", float) = 1.0
            [VerticalBoxEnd]_FireMaskSubEnd("",int) = 0
        [VerticalBoxEnd]_FireMaskEnd("",int) = 0
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

                static const float PI2 = 6.28318530718f;

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

                fixed4 _Color, _FireScale, _FireWiggle, _FireWiggleSpeed;
                sampler2D _FireMask;
                fixed4 _FireMask_ST;
                fixed _FireWidth, _FireHeight, _FireXPosition, _FireYPosition, _FireXPow, _FireYPow;
                fixed _FireMaskPow, _FireMaskMainSize, _FireMaskSubSize, _FireMaskMainSpeed, _FireMaskSubSpeed;

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
                    fixed4 multMask = tex2D(_FireMask, i.textureUv * 1.0f/_FireMaskMainSize + fixed2(0.0f, (_Time.y/_FireMaskMainSize * _FireMaskMainSpeed)%1.0f));
                    fixed4 multSubMask = tex2D(_FireMask, i.textureUv * 1.0f/_FireMaskSubSize + fixed2(0.0f, (_Time.y/_FireMaskSubSize * _FireMaskSubSpeed)%1.0f));
                    float x = (i.uv.x - _FireXPosition) * 1.0f/(((1.0f - i.uv.y) * _FireScale.w * _FireWidth) + (i.uv.y * _FireScale.z * _FireWidth)) + _FireXPosition;
                    float y = (i.uv.y - _FireYPosition) * 1.0f/(((1.0f - i.uv.x) * _FireScale.y * _FireHeight) + (i.uv.x * _FireScale.x * _FireHeight)) + _FireYPosition;
                    x += ((1.0f - i.uv.y) * _FireWiggle.w * sin((_Time.y * _FireWiggleSpeed.w)%PI2)) + (i.uv.y * _FireWiggle.z * cos((_Time.y * _FireWiggleSpeed.z)%PI2));
                    y += ((1.0f - i.uv.x) * _FireWiggle.y * sin((_Time.y * _FireWiggleSpeed.y)%PI2)) + (i.uv.x * _FireWiggle.x * cos((_Time.y * _FireWiggleSpeed.x)%PI2));
                    
                    float maskMultiplier = pow(saturate(sqrt(pow((_FireXPosition - x), 2.0f) + pow((_FireYPosition - y), 2.0f))), _FireMaskPow);

                    y += y * multMask.x * maskMultiplier;
                    x += x * multSubMask.x * maskMultiplier;
                    
                    fixed4 col = fixed4(0.0f, 0.0f, 0.0f, 0.0f);
                    col += saturate(1.0f - sqrt(pow((_FireXPosition - x), 2.0f) + pow((_FireYPosition - y), 2.0f)));
                    col *= _Color;
                    UNITY_APPLY_FOG(i.fogCoord, col);
                    return col;
                }
            ENDCG
        }
    }
}