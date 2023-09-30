Shader "Hidden/ChromaticAborration"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
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
            float2 _OffsetDirection;
            float _OffsetAmount;

            fixed4 frag (v2f IN) : SV_Target
            {
                if (_Swipe < IN.uv.x) return tex2D(_MainTex, IN.uv);

                float2 offset = normalize(_OffsetDirection) * _OffsetAmount;
                offset *= length(IN.uv - 0.5); 

                fixed r = tex2D(_MainTex, IN.uv + offset).r;
                fixed g = tex2D(_MainTex, IN.uv).g;
                fixed b = tex2D(_MainTex, IN.uv - offset).b;

                return fixed4(r, g, b, 1);
            }
            ENDCG
        }
    }
}
