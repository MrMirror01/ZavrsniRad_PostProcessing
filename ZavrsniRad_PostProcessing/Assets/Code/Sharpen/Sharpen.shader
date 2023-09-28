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
        ENDCG

        Pass
        {
            Name "BoxSharpen"

            CGPROGRAM
            /*static const float kernel[9] = {
                -1, -1, -1,
                -1, 9, -1,
                -1, -1, -1
            };*/
            static const float kernel[9] = {
                0, -1, 0,
                -1, 5, -1,
                0, -1, 0
            };

            fixed3 getSharpenColor(float2 uv){
                fixed3 sherpenCol = 0; //boja izostrenog piksela
                float totalWeight = 0;

                //uzimamo uzorke na 3x3 piksela sa centrom u trenutnom pikselu
                //primjenjujemo konvoluciju za izoštravanje
                for (int i = -1; i <= 1; i++){
                    for (int j = -1; j <= 1; j++){
                        float weight = kernel[(i + 1) * 3 + j + 1];
                        sherpenCol += tex2D(_MainTex, uv + _MainTex_TexelSize.xy * float2(i, j)).rgb * weight;
                    }
                }

                return sherpenCol.rgb;
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
