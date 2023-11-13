Shader "Hidden/ColorQuantization"
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

        static const int mapSize = 4;
        static const float ditherMap8x8[64] = { 0, 32, 8, 40, 2, 34, 10, 42, 48, 16, 56, 24, 50, 18, 58, 26, 12, 44, 4, 36, 14, 46, 6, 38, 60, 28, 52, 20, 62, 30, 54, 22, 3, 35, 11, 43, 1, 33, 9, 41, 51, 19, 59, 27, 49, 17, 57, 25, 15, 47, 7, 39, 13, 45, 5, 37, 63, 31, 55, 23, 61, 29, 53, 21 };
        static const float ditherMap4x4[16] = { 0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5 };

        sampler2D _MainTex;
        //Unity automatski postavlja vrijednost na {1 / sirina teksture, 1 / visina teksture, sirina teksture, visina teksture}
        //gdje je 1 / sirina teksture = sirina pikesla u UV koordinatama
        float4 _MainTex_TexelSize;
        float _Swipe;
        float _Spread;
        int _NumberOfColors;
        
        ENDCG

        Pass {
            Name "NoPalette"

            CGPROGRAM
            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                int x = IN.uv.x * _MainTex_TexelSize.z;
                int y = IN.uv.y * _MainTex_TexelSize.w;
                x %= mapSize;
                y %= mapSize;

                float mapValue = ditherMap4x4[mapSize * x + y] / (mapSize * mapSize) - 0.5;
                col.rgb += _Spread * mapValue;

                col.rgb = floor(col.rgb * (_NumberOfColors - 1) + 0.5) / (_NumberOfColors - 1);

                return col;
            }
            ENDCG
        }

        Pass {
            Name "Palette"

            CGPROGRAM
            sampler2D _Palette;

            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                float gray = dot(col.rgb, float3(0.299, 0.587, 0.144));

                int x = IN.uv.x * _MainTex_TexelSize.z;
                int y = IN.uv.y * _MainTex_TexelSize.w;
                x %= mapSize;
                y %= mapSize;

                float mapValue = ditherMap4x4[mapSize * x + y] / (mapSize * mapSize) - 0.5;
                gray += _Spread * mapValue;

                gray = floor(gray * (_NumberOfColors - 1) + 0.5) / (_NumberOfColors - 1);

                return tex2D(_Palette, float2(gray, 0.5));
            }
            ENDCG
        }
    }
}
