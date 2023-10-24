Shader "Hidden/Sharpen"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        CGINCLUDE
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            //Unity automatski postavlja vrijednost na {1 / sirina teksture, 1 / visina teksture, sirina teksture, visina teksture}
            //gdje je 1 / sirina teksture = sirina pikesla u UV koordinatama
            float4 _MainTex_TexelSize;
            float _Swipe;
            float _SharpnessStrength;
        ENDCG

        Pass
        {
            Name "BoxSharpen"

            CGPROGRAM

            fixed3 getSharpenColor(float2 uv){

                float3 center = tex2D(_MainTex, uv).rgb * (4 * _SharpnessStrength + 1);
                float3 up     = tex2D(_MainTex, uv + _MainTex_TexelSize.xy * float2(0, 1)).rgb * _SharpnessStrength;
                float3 down   = tex2D(_MainTex, uv + _MainTex_TexelSize.xy * float2(0, -1)).rgb * _SharpnessStrength;
                float3 left   = tex2D(_MainTex, uv + _MainTex_TexelSize.xy * float2(-1, 0)).rgb * _SharpnessStrength;
                float3 right  = tex2D(_MainTex, uv + _MainTex_TexelSize.xy * float2(1, 0)).rgb * _SharpnessStrength;

                return center - up - down - left - right;
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                //procitamo boju piksela
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                return fixed4(getSharpenColor(IN.uv), 1.0);
            }
            ENDCG
        }

        Pass
        {
            Name "AdaptiveSharpen"

            CGPROGRAM

            fixed3 sample(float2 uv, int x, int y){
                return tex2D(_MainTex, uv + _MainTex_TexelSize.xy * float2(x, y)).rgb;
            }

            fixed3 getSharpenColor(float2 uv){
                float sharpness = -(1.0 / lerp(10.0, 4.0, saturate(_SharpnessStrength)));

                float3 a = sample(uv, -1, -1); //d
                float3 b = sample(uv,  0, -1); //o
                float3 c = sample(uv,  1, -1); //d
                float3 d = sample(uv, -1,  0); //o
                float3 e = sample(uv,  0,  0); //o
                float3 f = sample(uv,  1,  0); //o
                float3 g = sample(uv, -1,  1); //d
                float3 h = sample(uv,  0,  1); //o
                float3 i = sample(uv,  1,  1); //d

                float3 miniOrtho = 1, miniDiag = 1;
                miniOrtho = min(miniOrtho, min(b, min(d, min(e, min(f, h)))));
                miniDiag = min(miniDiag, min(a, min(c, min(g, i))));
                float3 mini = miniOrtho + miniDiag;

                float3 maxiOrtho = 0, maxiDiag = 0;
                maxiOrtho = max(maxiOrtho, max(b, max(d, max(e, max(f, h)))));
                maxiDiag = max(maxiDiag, max(a, max(c, max(g, i))));
                float3 maxi = maxiOrtho + maxiDiag;

                float3 amplitude = saturate(min(mini, 2.0 - maxi) / maxi);
                amplitude = sqrt(amplitude);

                float weight = amplitude * sharpness;
                float reciprocalWeight = 1.0 / (1.0 + 4.0 * weight);

                return saturate((b * weight + d * weight + f * weight + h * weight + e) * reciprocalWeight);
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                //procitamo boju piksela
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                return fixed4(getSharpenColor(IN.uv), 1.0);
            }
            ENDCG
        }
    }
}
