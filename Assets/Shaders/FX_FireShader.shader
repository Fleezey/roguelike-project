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
        _FireDirection ("Fire Direction", range(0.0, 1.0)) = 0.0
            [VerticalBoxStart(Fire Mask Main, 2)]_FireMaskMainStart("",int) = 0
            _FireMaskMainSize ("Fire Mask Main Size", float) = 1.0
            _FireMaskMainSpeed ("Fire Mask Main Speed", float) = 1.0
            [VerticalBoxEnd]_FireMaskMainEnd("",int) = 0
            [VerticalBoxStart(Fire Sub Mask, 2)]_FireMaskSubStart("",int) = 0
            _FireMaskSubSize ("Fore Mask Sub Size", float) = 1.0
            _FireMaskSubSpeed ("Fore Mask Sub Speed", float) = 1.0
            [VerticalBoxEnd]_FireMaskSubEnd("",int) = 0
        [VerticalBoxEnd]_FireMaskEnd("",int) = 0

        [VerticalBoxStart(Fire Displacement)]_FireDisplacementStart("",int) = 0
        _FireDisplacement ("Fire Displacement", float) = 0.0
        _FireMovePow ("Fire Move Power", float) = 1.0
        _FireMoveSpeed ("Fire Move Speed", float) = 1.0
        _FireMoveIntensity ("Fire Move Intensity", float) = 1.0
        [VerticalBoxEnd]_FireDisplacementEnd("",int) = 0
    }

    SubShader {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 200
        //Cull Off

        Pass {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                #pragma multi_compile_fog

                #include "UnityCG.cginc"
                #include "UnityLightingCommon.cginc"

                static const float PI2 = 6.28318530718f;
                static const float randomF = 0.9283017492835;

                struct a2v {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                    float3 normal : NORMAL;
                };

                struct v2f {
                    float4 vertex : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    float2 mainUv : TEXCOORD1;
                    float2 subUv : TEXCOORD2;
                };

                fixed4 _Color, _FireScale, _FireWiggle, _FireWiggleSpeed;
                sampler2D _FireMask;
                fixed4 _FireMask_ST;
                fixed _FireWidth, _FireHeight, _FireXPosition, _FireYPosition, _FireXPow, _FireYPow, _FireDirection;
                fixed _FireDisplacement, _FireMovePow, _FireMoveSpeed, _FireMoveIntensity;
                fixed _FireMaskPow, _FireMaskMainSize, _FireMaskSubSize, _FireMaskMainSpeed, _FireMaskSubSpeed;

                // Main uv function
                float2 mUv (fixed2 uv, fixed rV, fixed2 modU, fixed2 dir)
                {
                    fixed windMainSpeed = (_Time.y/_FireMaskMainSize * _FireMaskMainSpeed)%1.0;
                    return (uv * 1.0f/_FireMaskMainSize + fixed2(windMainSpeed * dir.x + dir.x * rV , windMainSpeed * dir.y + dir.y * rV));
                }

                // Sub uv function
                float2 sUv (fixed2 uv, fixed rV, fixed2 modU, fixed2 dir)
                {
                    fixed windSubSpeed = (_Time.y/_FireMaskSubSize * _FireMaskSubSpeed)%1.0f;
                    return (uv * 1.0f/_FireMaskSubSize + fixed2(windSubSpeed * dir.x + dir.x * rV , windSubSpeed * dir.y + dir.y * rV));
                }

                v2f vert (a2v v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    
                    fixed randomV = float(floor(pow(10, abs(floor(o.uv.x))) * randomF)%10) / 10.0;
                    fixed2 moduloUv = fixed2(o.uv.x%1.0f, o.uv.y);
                    fixed2 direction = fixed2(cos(_FireDirection * PI2), sin(_FireDirection * PI2));

                    o.mainUv = TRANSFORM_TEX(v.uv, _FireMask);
                    o.subUv = TRANSFORM_TEX(v.uv, _FireMask);
                    o.mainUv = mUv(o.mainUv, randomV, moduloUv, direction);
                    o.subUv = sUv(o.subUv, randomV, moduloUv, direction);
                    o.uv = moduloUv;

                    //o.vertex.xyz += v.normal * tex2Dlod(_FireMask, float4(o.mainUv + fixed2(0.0, randomV),0,0)).r * _FireDisplacement;
                    o.vertex.xyz += v.normal * (sin(_Time.y * _FireMoveSpeed)%PI2 - 1.0f) * _FireMoveIntensity * pow(o.uv.y, _FireMovePow);
                    //float pulseMask = length(o.uv.y%1.0f - (_Time.y)%1.0f) * length((o.uv.y - 1.0f)%1.0f - (_Time.y)%1.0f);
                    //pulseMask = saturate(pow(lerp(0.0f, 1.0f, pulseMask), 1.0f));
                    //o.vertex.y += (1.0f - pulseMask) * 5.0f;
                    return o;
                }

                fixed4 frag (v2f i) : COLOR
                {   
                    // Black & White Mask
                    fixed4 multMask = tex2D(_FireMask,  i.mainUv);
                    fixed4 multSubMask = tex2D(_FireMask, i.subUv);
                    
                    float x = (i.uv.x - _FireXPosition) * 1.0f/(((1.0f - i.uv.y) * _FireScale.w * _FireWidth) + (i.uv.y * _FireScale.z * _FireWidth)) + _FireXPosition;
                    float y = (i.uv.y - _FireYPosition) * 1.0f/(((1.0f - i.uv.x) * _FireScale.y * _FireHeight) + (i.uv.x * _FireScale.x * _FireHeight)) + _FireYPosition;
                    x += (((1.0f - i.uv.y) * _FireWiggle.w * sin((_Time.y * _FireWiggleSpeed.w)%PI2)) + (i.uv.y * _FireWiggle.z * cos((_Time.y * _FireWiggleSpeed.z)%PI2)));
                    y += (((1.0f - i.uv.x) * _FireWiggle.y * sin((_Time.y * _FireWiggleSpeed.y)%PI2)) + (i.uv.x * _FireWiggle.x * cos((_Time.y * _FireWiggleSpeed.x)%PI2)));
                    
                    float maskMultiplier = pow(saturate(sqrt(pow((_FireXPosition - x), 2.0f) + pow((_FireYPosition - y), 2.0f))), _FireMaskPow);

                    float pulse = (_Time.y * 5.5f)%1.0f;
                    float pulseMask = abs(-y + pulse) * abs(-y + 2.0f + pulse) * abs(-y - 2.0f + pulse);
                    pulseMask = saturate(lerp(0.15f, 1.0f, pow(pulseMask, 8.0f)));

                    y += y * multMask.x * maskMultiplier;
                    x += x * multSubMask.x * maskMultiplier;
                    
                    fixed4 col = fixed4(0.0f, 0.0f, 0.0f, 0.0f);
                    col += saturate(1.0f - sqrt(pow((_FireXPosition - x), 2.0f) + pow((_FireYPosition - y), 2.0f)));
                    col *= _Color;
                    col.rgb *= 5.0f;
                    //col.rgb *= pulseMask;
                    return col;
                }
            ENDCG
        }
    }
    FallBack "Diffuse"
}