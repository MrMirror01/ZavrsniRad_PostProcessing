Shader "Hidden/DepthOfField"
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
            float4 _MainTex_TexelSize;
            sampler2D _CameraDepthTexture;
            sampler2D _CircleOfConfusion;
            float _Distance;
            float _Radius;

            float getDepth(float2 uv){
                //_ProjectionParams = {1.0, near, far, 1/far}
                float near = _ProjectionParams.y;
                float far = _ProjectionParams.z;
                float depth = 1.0 - tex2D(_CameraDepthTexture, uv);
                
                //linerize depth
                depth = (1 - far / near) * depth + (far / near);
                depth = 1.0 / depth;

                depth *= far; //udaljenost od kamere u world space-u
                
                return depth;
            }
        ENDCG

        Pass
        {
            Name "GetCircleOfConfusion"

            CGPROGRAM
            fixed4 frag (v2f IN) : SV_Target
            {
                float depth = getDepth(IN.uv);
                
                if (depth < _Distance - _Radius){
                    return fixed4(1.0, 0, 0, 1.0);
                }
                if (depth <= _Distance){
                    return fixed4((_Distance - depth) / _Radius, 0, 0, 1.0);
                }
                if (depth <= _Distance + _Radius){
                    return fixed4(0, 1.0 - (_Distance + _Radius - depth) / _Radius, 0, 1.0);
                }
                return fixed4(0, 1.0, 0, 1.0);
            }
            ENDCG
        }

        Pass
        {
            Name "MaxFilterNear"

            CGPROGRAM
            fixed getMax(float2 uv){
                fixed3 maxr = 0;

                //uzimamo uzorke na 7x7 piksela sa centrom u trenutnom pikselu
                for (int i = -3; i <= 3; i++){
                    for (int j = -3; j <= 3; j++){
                        maxr = max(maxr, tex2D(_MainTex, uv + _MainTex_TexelSize.xy * float2(i, j)).r);
                    }
                }

                return maxr;
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                //procitamo boju piksela
                fixed4 col = tex2D(_MainTex, IN.uv);

                col.r = getMax(IN.uv);

                return col;
            }
            ENDCG
        }

        Pass
        {
            Name "BoxBlurNear"

            CGPROGRAM
            fixed getBlurCol(float2 uv){
                fixed blurcol = 0; //boja zamucenog piksela

                //uzimamo uzorke na 7x7 piksela sa centrom u trenutnom pikselu
                //izracunavamo aritmeticku sredinu boja
                for (int i = -3; i <= 3; i++){
                    for (int j = -3; j <= 3; j++){
                        blurcol += tex2D(_MainTex, uv + _MainTex_TexelSize.xy * float2(i, j)).r;
                    }
                }
                blurcol /= 49;

                return blurcol;
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                //procitamo boju piksela
                fixed4 col = tex2D(_MainTex, IN.uv);

                col.r = getBlurCol(IN.uv);

                return col;
            }
            ENDCG
        }

        Pass
        {
            Name "GetFar"

            CGPROGRAM
            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);

                return fixed4(col.rgb * tex2D(_CircleOfConfusion, IN.uv).g, 1.0);
            }
            ENDCG
        }

        Pass
        {
            Name "MergeFar"
            
            CGPROGRAM
            sampler2D _Far;
            
            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);

                return lerp(col, tex2D(_Far, IN.uv), tex2D(_CircleOfConfusion, IN.uv).g);
            }
            ENDCG
        }

        Pass
        {
            Name "MergeNear"

            CGPROGRAM
            sampler2D _Near;

            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);

                return lerp(col, tex2D(_Near, IN.uv), tex2D(_CircleOfConfusion, IN.uv).r);
            }
            ENDCG
        }
    }
}
