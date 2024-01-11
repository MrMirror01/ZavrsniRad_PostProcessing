Shader "Hidden/Blur"
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
            float _KernelSize;
        ENDCG

        Pass
        {
            Name "BoxBlur"

            CGPROGRAM

            fixed3 getBlurCol(float2 uv){
                fixed3 blurcol = 0; //boja zamucenog piksela

                //uzimamo uzorke na 7x7 piksela sa centrom u trenutnom pikselu
                //izracunavamo aritmeticku sredinu boja
                for (int i = -3; i <= 3; i++){
                    for (int j = -3; j <= 3; j++){
                        blurcol += tex2D(_MainTex, uv + _KernelSize * _MainTex_TexelSize.xy * float2(i, j)).rgb;
                    }
                }
                //rezultat podijelimo sa ukupnim brojem uzoraka
                blurcol /= 49;

                return blurcol.rgb; //vratimo dobivenu boju
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                //procitamo boju piksela
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                return fixed4(getBlurCol(IN.uv), 1.0);
            }
            ENDCG
        }

        Pass
        {
            Name "WeightedByDistance"

            CGPROGRAM
            fixed3 getBlurCol(float2 uv){
                fixed3 blurcol = 0; //boja zamucenog piksela

                //uzimamo uzorke na 7x7 piksela sa centrom u trenutnom pikselu
                //izracunavamo sredinu boja tako da pikseli blize trenutnom pikselu vise utjecu na finalni rezultat
                float totalWeight = 0;
                for (int i = -3; i <= 3; i++){
                    for (int j = -3; j <= 3; j++){
                        float weight = length(float2(i, j));
                        totalWeight += weight;
                        blurcol += tex2D(_MainTex, uv + _KernelSize * _MainTex_TexelSize.xy * float2(i, j)).rgb * weight;
                    }
                }
                blurcol /= totalWeight;

                return blurcol.rgb;
            }
            
            fixed4 frag (v2f IN) : SV_Target
            {
                //procitamo boju piksela
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                return fixed4(getBlurCol(IN.uv), 1.0);
            }
            ENDCG
        }

        Pass
        {
            Name "BokehBlur"

            CGPROGRAM
            // Okrugli kernel iz znanstvenog rada: GPU Zen 'Practical Gather-based Bokeh Depth of Field' by Wojciech Sterna
            static const float2 offsets[] =
            {
                float2(0.000000, 0.000000),

            	2.0 * float2(1.000000, 0.000000),
            	2.0 * float2(0.707107, 0.707107),
            	2.0 * float2(-0.000000, 1.000000),
            	2.0 * float2(-0.707107, 0.707107),
            	2.0 * float2(-1.000000, -0.000000),
            	2.0 * float2(-0.707106, -0.707107),
            	2.0 * float2(0.000000, -1.000000),
            	2.0 * float2(0.707107, -0.707107),
            	
            	4.0 * float2(1.000000, 0.000000),
            	4.0 * float2(0.923880, 0.382683),
            	4.0 * float2(0.707107, 0.707107),
            	4.0 * float2(0.382683, 0.923880),
            	4.0 * float2(-0.000000, 1.000000),
            	4.0 * float2(-0.382684, 0.923879),
            	4.0 * float2(-0.707107, 0.707107),
            	4.0 * float2(-0.923880, 0.382683),
            	4.0 * float2(-1.000000, -0.000000),
            	4.0 * float2(-0.923879, -0.382684),
            	4.0 * float2(-0.707106, -0.707107),
            	4.0 * float2(-0.382683, -0.923880),
            	4.0 * float2(0.000000, -1.000000),
            	4.0 * float2(0.382684, -0.923879),
            	4.0 * float2(0.707107, -0.707107),
            	4.0 * float2(0.923880, -0.382683),
            
            	6.0 * float2(1.000000, 0.000000),
            	6.0 * float2(0.965926, 0.258819),
            	6.0 * float2(0.866025, 0.500000),
            	6.0 * float2(0.707107, 0.707107),
            	6.0 * float2(0.500000, 0.866026),
            	6.0 * float2(0.258819, 0.965926),
            	6.0 * float2(-0.000000, 1.000000),
            	6.0 * float2(-0.258819, 0.965926),
            	6.0 * float2(-0.500000, 0.866025),
            	6.0 * float2(-0.707107, 0.707107),
            	6.0 * float2(-0.866026, 0.500000),
            	6.0 * float2(-0.965926, 0.258819),
            	6.0 * float2(-1.000000, -0.000000),
            	6.0 * float2(-0.965926, -0.258820),
            	6.0 * float2(-0.866025, -0.500000),
            	6.0 * float2(-0.707106, -0.707107),
            	6.0 * float2(-0.499999, -0.866026),
            	6.0 * float2(-0.258819, -0.965926),
            	6.0 * float2(0.000000, -1.000000),
            	6.0 * float2(0.258819, -0.965926),
            	6.0 * float2(0.500000, -0.866025),
            	6.0 * float2(0.707107, -0.707107),
            	6.0 * float2(0.866026, -0.499999),
            	6.0 * float2(0.965926, -0.258818),
            };
            
            fixed3 getBlurCol(float2 uv){
                fixed3 blurcol = 0; //boja zamucenog piksela
                float weightSum = 0;

                //uzimamo uzorke na 49 uzorka u obliku kruga sa centrom u trenutnom pikeslu
                for (int i = 0; i < 49; i++){
                    fixed3 col = tex2D(_MainTex, uv + _KernelSize * _MainTex_TexelSize.xy * offsets[i]).rgb;

                    blurcol += col;
                }

                return blurcol.rgb / 49.0;
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                //procitamo boju piksela
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                return fixed4(getBlurCol(IN.uv), 1.0);
            }
            ENDCG
        }

        Pass
        {
            Name "BokehBlurWithInverseKarisAverage"

            CGPROGRAM
            // Okrugli kernel iz znanstvenog rada: GPU Zen 'Practical Gather-based Bokeh Depth of Field' by Wojciech Sterna
            static const float2 offsets[] =
            {
                float2(0.000000, 0.000000),

            	2.0 * float2(1.000000, 0.000000),
            	2.0 * float2(0.707107, 0.707107),
            	2.0 * float2(-0.000000, 1.000000),
            	2.0 * float2(-0.707107, 0.707107),
            	2.0 * float2(-1.000000, -0.000000),
            	2.0 * float2(-0.707106, -0.707107),
            	2.0 * float2(0.000000, -1.000000),
            	2.0 * float2(0.707107, -0.707107),
            	
            	4.0 * float2(1.000000, 0.000000),
            	4.0 * float2(0.923880, 0.382683),
            	4.0 * float2(0.707107, 0.707107),
            	4.0 * float2(0.382683, 0.923880),
            	4.0 * float2(-0.000000, 1.000000),
            	4.0 * float2(-0.382684, 0.923879),
            	4.0 * float2(-0.707107, 0.707107),
            	4.0 * float2(-0.923880, 0.382683),
            	4.0 * float2(-1.000000, -0.000000),
            	4.0 * float2(-0.923879, -0.382684),
            	4.0 * float2(-0.707106, -0.707107),
            	4.0 * float2(-0.382683, -0.923880),
            	4.0 * float2(0.000000, -1.000000),
            	4.0 * float2(0.382684, -0.923879),
            	4.0 * float2(0.707107, -0.707107),
            	4.0 * float2(0.923880, -0.382683),
            
            	6.0 * float2(1.000000, 0.000000),
            	6.0 * float2(0.965926, 0.258819),
            	6.0 * float2(0.866025, 0.500000),
            	6.0 * float2(0.707107, 0.707107),
            	6.0 * float2(0.500000, 0.866026),
            	6.0 * float2(0.258819, 0.965926),
            	6.0 * float2(-0.000000, 1.000000),
            	6.0 * float2(-0.258819, 0.965926),
            	6.0 * float2(-0.500000, 0.866025),
            	6.0 * float2(-0.707107, 0.707107),
            	6.0 * float2(-0.866026, 0.500000),
            	6.0 * float2(-0.965926, 0.258819),
            	6.0 * float2(-1.000000, -0.000000),
            	6.0 * float2(-0.965926, -0.258820),
            	6.0 * float2(-0.866025, -0.500000),
            	6.0 * float2(-0.707106, -0.707107),
            	6.0 * float2(-0.499999, -0.866026),
            	6.0 * float2(-0.258819, -0.965926),
            	6.0 * float2(0.000000, -1.000000),
            	6.0 * float2(0.258819, -0.965926),
            	6.0 * float2(0.500000, -0.866025),
            	6.0 * float2(0.707107, -0.707107),
            	6.0 * float2(0.866026, -0.499999),
            	6.0 * float2(0.965926, -0.258818),
            };
            
            fixed3 getBlurCol(float2 uv){
                fixed3 blurcol = 0; //boja zamucenog piksela
                float weightSum = 0;

                //uzimamo uzorke na 49 uzorka u obliku kruga sa centrom u trenutnom pikeslu
                for (int i = 0; i < 49; i++){
                    fixed3 col = tex2D(_MainTex, uv + _KernelSize * _MainTex_TexelSize.xy * offsets[i]).rgb;

                    //weight by luminance (inverse Karis average)
                    float lum = dot(col.rgb, float3(0.299, 0.587, 0.144)); //luminance of pixel
                    float weight = lum + 1.;
                    weightSum += weight;
                    blurcol += col * weight;
                }

                return blurcol.rgb / weightSum;
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                //procitamo boju piksela
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                return fixed4(getBlurCol(IN.uv), 1.0);
            }
            ENDCG
        }

        Pass
        {
            Name "GaussianBlur"

            CGPROGRAM
            static const float gaussianKernel[49] = {
                0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067,
                0.00002292, 0.00078633, 0.00655965, 0.01330373, 0.00655965, 0.00078633, 0.00002292,
                0.00019117, 0.00655965, 0.05472157, 0.11098164, 0.05472157, 0.00655965, 0.00019117,
                0.00038771, 0.01330373, 0.11098164, 0.22508352, 0.11098164, 0.01330373, 0.00038771,
                0.00019117, 0.00655965, 0.05472157, 0.11098164, 0.05472157, 0.00655965, 0.00019117,
                0.00002292, 0.00078633, 0.00655965, 0.01330373, 0.00655965, 0.00078633, 0.00002292,
                0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067
            };

            fixed3 getBlurCol(float2 uv){
                fixed3 blurcol = 0; //boja zamucenog piksela
                float totalWeight = 0;

                //uzimamo uzorke na 5x5 piksela sa centrom u trenutnom pikselu
                //izracunavamo sredinu boja tako da pikseli blize trenutnom pikselu vise utjecu na finalni rezultat
                //ali prema normaliziranoj Gausovoj distribuciji koja je izracunata unaprijed i zapisana u matricu 'gaussianKernel'
                for (int i = -3; i <= 3; i++){
                    for (int j = -3; j <= 3; j++){
                        float weight = gaussianKernel[(i + 3) * 7 + j + 3];
                        blurcol += tex2D(_MainTex, uv + _KernelSize * _MainTex_TexelSize.xy * float2(i, j)).rgb * weight;
                    }
                }

                return blurcol.rgb;
            }
            
            fixed4 frag (v2f IN) : SV_Target
            {
                //procitamo boju piksela
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                return fixed4(getBlurCol(IN.uv), 1.0);
            }
            ENDCG
        }

        Pass
        {
            Name "OptimisedGaussianHorizontal"

            CGPROGRAM
            static const float optimisedGaussianKernel[7] = {
                0.0014439178187225007,
                0.035614480755336686,
                0.23877678696410898,
                0.44832962892366385,
                0.23877678696410898,
                0.035614480755336686,
                0.0014439178187225007
            };

            fixed3 getBlurCol(float2 uv){
                fixed3 blurcol = 0; //boja zamucenog piksela
                float totalWeight = 0;

                //uzimamo uzorke na 5 piksela u redu sa centrom u trenutnom pikselu
                //izracunavamo sredinu boja tako da pikseli blize trenutnom pikselu vise utjecu na finalni rezultat
                //ali prema normaliziranoj Gausovoj distribuciji koja je izracunata unaprijed i zapisana u matricu 'optimisedGaussianKernel'
                for (int i = -3; i <= 3; i++){
                    float weight = optimisedGaussianKernel[(i + 3)];
                    blurcol += tex2D(_MainTex, uv + float2(_KernelSize * _MainTex_TexelSize.x * i, 0)).rgb * weight;
                }

                return blurcol.rgb;
            }
            
            fixed4 frag (v2f IN) : SV_Target
            {
                //procitamo boju piksela
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                return fixed4(getBlurCol(IN.uv), 1.0);
            }
            ENDCG
        }

        Pass
        {
            Name "OptimisedGaussianVertical"

            CGPROGRAM
            static const float optimisedGaussianKernel[7] = {
                0.0014439178187225007,
                0.035614480755336686,
                0.23877678696410898,
                0.44832962892366385,
                0.23877678696410898,
                0.035614480755336686,
                0.0014439178187225007
            };

            fixed3 getBlurCol(float2 uv){
                fixed3 blurcol = 0; //boja zamucenog piksela
                float totalWeight = 0;

                //uzimamo uzorke na 5 piksela u stupcu sa centrom u trenutnom pikselu
                //izracunavamo sredinu boja tako da pikseli blize trenutnom pikselu vise utjecu na finalni rezultat
                //ali prema normaliziranoj Gausovoj distribuciji koja je izracunata unaprijed i zapisana u matricu 'optimisedGaussianKernel'
                for (int i = -3; i <= 3; i++){
                    float weight = optimisedGaussianKernel[(i + 3)];
                    blurcol += tex2D(_MainTex, uv + float2(0, _KernelSize * _MainTex_TexelSize.y * i)).rgb * weight;
                }

                return blurcol.rgb;
            }
            
            fixed4 frag (v2f IN) : SV_Target
            {
                //procitamo boju piksela
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                return fixed4(getBlurCol(IN.uv), 1.0);
            }
            ENDCG
        }
    }
}
