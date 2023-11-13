Shader "Hidden/ColorCorrection"
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
            float _Brightness;
            float _Contrast;
            float _Saturation;
            float _Gamma;

            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                col.rgb = saturate(col.rgb); //zakvacimo boje u interval [0, 1]

                col.rgb = pow(col.rgb, 1 / 2.2); //prebacimo boje iz gamma space-a u linear space
                
                col.rgb = _Contrast * (col.rgb - 0.5) + 0.5 + _Brightness; //dodamo kontrast i svjetlinu
                col.rgb = saturate(col.rgb); //zakvacimo boje u interval [0, 1]

                //izracunamo 'crno-bijelu' vrijednost piksela, ali racunajuci na to da neke boje izgledaju svijetlije od drugih
                float3 gray = dot(col.rgb, float3(0.299, 0.587, 0.144));
                col.rgb = lerp(gray, col.rgb, _Saturation); //linearno interpoliramo izmedu 'crno-bijele' boje i prave boje koristeci 'Saturation'
                col.rgb = saturate(col.rgb); //zakvacimo boje u interval [0, 1]

                col.rgb = pow(col.rgb, _Gamma); //ispravljanje gamme, pocetna vrijednost je 2.2

                return col;
            }
            ENDCG
        }
    }
}
