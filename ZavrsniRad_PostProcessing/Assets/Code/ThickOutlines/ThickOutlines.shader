Shader "Hidden/ThickOutlines"
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
            float4 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture; //depth buffer camere -> sadrzi udaljenosti svakog piksela od kamere
            float _Swipe;
            int _Thickness; //kontrolira koliko je veliki uzorak na depth buffer-u te time i debljinu obruba
            float _DepthFactor; //broj kojim mnozimo izracunatu udaljenost; odreduje osijetljivost efekta na male promijene u udaljenosti
            float _Sharpness; //broj na koji potenciramo izracunatu udaljenost; odreduje 'brzinu otpadanja' obruba

            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);
                
                //izracunamo aritmeticku sredinu udaljenosti okolnih piksela od kamere
                float average = 0;
                int numOfSamples = 0;
                for (float i = -_Thickness; i < _Thickness; i++){
                    for (float j = -_Thickness; j < _Thickness; j++){
                        fixed4 sample = tex2D(_CameraDepthTexture, IN.uv + _MainTex_TexelSize.xy * float2(i, j));
                        average += sample.r;
                        numOfSamples++;
                    }
                }
                average /= numOfSamples;

                //izracunamo razliku sredisnje vrijednosti okolnih piksela i trenutnog piksela
                float depthDiff = abs(tex2D(_CameraDepthTexture, IN.uv).r - average);
                depthDiff *= _DepthFactor; //razliku pomnozimo sa '_DepthFactor' kako bismo odredili osijetljivost
                depthDiff = saturate(depthDiff); //zakljucamo vrijednost u rasponu 0-1
                depthDiff = pow(depthDiff, _Sharpness); //dobivenu vrijednost potenciramo kako bismo dobili 'ciste' obrube (manje postepenog otpadanja)

                float4 finalCol = col * (1. - depthDiff);

                if (_Swipe < IN.uv.x) return col;
                return finalCol;
            }
            ENDCG
        }
    }
}
