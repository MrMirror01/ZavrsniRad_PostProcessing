Shader "Hidden/ToneMapping"
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
            float _Swipe;
        ENDCG
        
        Pass{
            Name "ExtendedReinhard"

            CGPROGRAM
            float _WhitePoint;

            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                float lum = dot(col.rgb, float3(0.299, 0.587, 0.144)); //luminance of pixel
                float wp2 = _WhitePoint * _WhitePoint;
                float3 tonemappedLuminance = (1 + (lum / wp2)) / (1 + lum); //tone mapping

                return fixed4(col.rgb * tonemappedLuminance, 1);
            }
            ENDCG
        }

        Pass{
            Name "Lottes"

            CGPROGRAM

            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                float lum = dot(col.rgb, float3(0.299, 0.587, 0.144)); //luminance of pixel

                return fixed4(col.rgb * rcp(1 + lum), 1.0); //rcp = reciprocni broj
            }
            ENDCG
        }

        Pass
        {
            Name "InverseExtendedReinhard"

            CGPROGRAM
            float _WhitePoint;

            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                float lum = dot(col.rgb, float3(0.299, 0.587, 0.144)); //luminance of pixel
                //half3 tonemappedLuminance = lum * (1 + (lum / (_WhitePoint * _WhitePoint))) / (1 + lum); //tone mapping

                col.rgb = saturate(col.rgb);
                return fixed4(col.rgb / (_WhitePoint * max(1.0 - col.rgb / _WhitePoint, 0.001)), 1);
            }
            ENDCG
        }

        Pass
        {
            Name "InverseLottes"

            CGPROGRAM
            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                float lum = dot(col.rgb, float3(0.299, 0.587, 0.144)); //luminance of pixel

                return fixed4(saturate(col.rgb) * rcp(1 - lum), 1.0); //rcp = reciprocni broj
            }
            ENDCG
        }
    }
}
