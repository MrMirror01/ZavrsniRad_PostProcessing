Shader "Hidden/AdvancedColorCorrection"
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
            int _HDR;
            float _Exposure;
            float _Temperature;
            float _Tint;
            float3 _Contrast;
            float3 _Brightness;
            float3 _Saturation;
            float3 _ColorFilter;
            float _Gamma;

            static const float3x3 LIN_2_LMS_MAT = {
                3.90405e-1, 5.49941e-1, 8.92632e-3,
                7.08416e-2, 9.63172e-1, 1.35775e-3,
                2.31082e-2, 1.28021e-1, 9.36245e-1
            };

            static const float3x3 LMS_2_LIN_MAT = {
                2.85847e+0, -1.62879e+0, -2.48910e-2,
                -2.10182e-1,  1.15820e+0,  3.24281e-4,
                -4.18120e-2, -1.18169e-1,  1.06867e+0
            };

            fixed3 wBalance(float3 col, float temp, float tint){
                float t1 = temp * 10 / 6;
                float t2 = tint * 10 / 6;

                // Get the CIE xy chromaticity of the reference white point.
                // Note: 0.31271 = x value on the D65 white point
                float x = 0.31271 - t1 * (t1 < 0 ? 0.1 : 0.05);
                float standardIllumY = 2.87 * x - 3 * x * x - 0.27509507;
                float y = standardIllumY + t2 * 0.05;

                // Calculate the coefficients in the LMS space.
                float3 w1 = float3(0.949237, 1.03542, 1.08728); // D65 white point
            
                // CIExyToLMS
                float Y = 1;
                float X = Y * x / y;
                float Z = Y * (1 - x - y) / y;
                float L = 0.7328 * X + 0.4296 * Y - 0.1624 * Z;
                float M = -0.7036 * X + 1.6975 * Y + 0.0061 * Z;
                float S = 0.0030 * X + 0.0136 * Y + 0.9834 * Z;
                float3 w2 = float3(L, M, S);

                float3 balance = float3(w1.x / w2.x, w1.y / w2.y, w1.z / w2.z);

                float3 lms = mul(LIN_2_LMS_MAT, col);
                lms *= balance;
                return mul(LMS_2_LIN_MAT, lms);
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x)
                    return col;

                col.rgb = pow(col.rgb, 1 / 2.2); //prebacimo boje iz gamma space-a u linear space

                //exposure
                col.rgb *= _Exposure;
                //zakvacimo boje u interval [0, 1] ili [0, beskonacno> ovisno o tome koristi li se HDR
                col.rgb = max(0, col.rgb);
                if (_HDR == 0) col.rgb = min(1, col.rgb); 

                //white balance
                col.rgb = wBalance(col.rgb, _Temperature, _Tint);
                //zakvacimo boje u interval [0, 1] ili [0, beskonacno> ovisno o tome koristi li se HDR
                col.rgb = max(0, col.rgb);
                if (_HDR == 0) col.rgb = min(1, col.rgb); 

                //contrast & brightness
                col.rgb = _Contrast * (col.rgb - 0.5) + 0.5 + _Brightness; //dodamo kontrast i svjetlinu
                //zakvacimo boje u interval [0, 1] ili [0, beskonacno> ovisno o tome koristi li se HDR
                col.rgb = max(0, col.rgb);
                if (_HDR == 0) col.rgb = min(1, col.rgb); 

                //saturation
                //izracunamo 'crno-bijelu' vrijednost piksela, ali racunajuci na to da neke boje izgledaju svijetlije od drugih
                float3 gray = dot(col.rgb, float3(0.299, 0.587, 0.144));
                col.rgb = lerp(gray, col.rgb, _Saturation); //linearno interpoliramo izmedu 'crno-bijele' boje i prave boje koristeci 'Saturation'
                col.rgb = max(0, col.rgb);
                if (_HDR == 0) col.rgb = min(1, col.rgb); 

                col.rgb *= _ColorFilter;
                //zakvacimo boje u interval [0, 1] ili [0, beskonacno> ovisno o tome koristi li se HDR
                col.rgb = max(0, col.rgb);
                if (_HDR == 0) col.rgb = min(1, col.rgb); 

                col.rgb = pow(col.rgb, _Gamma); //ispravljanje gamme, pocetna vrijednost je 2.2

                return col;
            }
            ENDCG
        }
    }
}
