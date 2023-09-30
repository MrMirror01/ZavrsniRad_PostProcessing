Shader "Hidden/FilmGrain"
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

            //uzima 'seed' vrijednost tipa uint i vraca pseudonasumican broj tipa uint
            uint hashi(uint x)
            {
                x ^= x >> 17;
                x *= uint(0xed5ad4bb);
                x ^= x >> 11;
                x *= uint(0xac4c1b51);
                x ^= x >> 15;
                x *= uint(0x31848bab);
                x ^= x >> 14;
                return x;
            }

            //uzima 'seed' vrijednost tipa uint i vraca pseudonasumican broj iz intervala [0, 1] tipa float
            float hash(uint x){
                return float(hashi(x)) / float(uint(0xffffffff)); //dijelimo sa maksimalnim mogucim brojem tipa uint
            }

            sampler2D _MainTex;
            //Unity automatski postavlja vrijednost na {1 / sirina teksture, 1 / visina teksture, sirina teksture, visina teksture}
            //gdje je 1 / sirina teksture = sirina pikesla u UV koordinatama
            float4 _MainTex_TexelSize;
            float _Swipe;
            float _Intensity;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                if (_Swipe < i.uv.x) return col;
                
                //coordinates of a pixel from 
                int2 pixelCoords = int2(int(_MainTex_TexelSize.z * i.uv.x), int(_MainTex_TexelSize.w * i.uv.y));
                float noise = frac( //funkcija koja uzima samo decimalni dio realnog broja (vraca broj u intervalu [0, 1])
                    10000 * sin(
                        hash(pixelCoords.x + hashi(pixelCoords.y)) //pseudonasumican broj koji ima razliciti 'seed' za svaki piksel (interval [0,1])
                        + _Time.y //dodajemo vrijeme kako bi se generirani broj mijenjao s vremenom (_Time je varijabla koju dodijeljuje Unity)
                    )
                ) - 0.5; //oduzimamo 0.5 kako bi premijestili iz intervala [0, 1] u interval [-0.5, 0.5]
                col.rgb += _Intensity * noise; //noise pomnozimo sa intenzitetom kako bi ga pojacali ili smanjili

                return col;
            }
            ENDCG
        }
    }
}
