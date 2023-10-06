Shader "Hidden/ScreenSpaceAmbientOcclusion"
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

        uint seed;
        //uzima 'seed' vrijednost tipa uint i vraca pseudonasumican broj iz intervala [0, 1] tipa float
        float hash(){
            seed = hashi(seed);
            return float(seed / float(uint(0xffffffff))); //dijelimo sa maksimalnim mogucim brojem tipa uint
        }

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        ENDCG


        Pass {
            Name "Noise"

            CGPROGRAM
            fixed4 frag (v2f IN) : SV_Target
            {
                uint2 pixelCoords = uint2(uint(_MainTex_TexelSize.z * IN.uv.x), uint(_MainTex_TexelSize.w * IN.uv.y));
                seed = hashi(pixelCoords.x + hashi(pixelCoords.y));

                float3 noise = float3(0,0,0);
                noise.x = hash() * 2 - 1; // [-1, 1]
                noise.y = hash() * 2 - 1; // [-1, 1]
                normalize(noise);

                return fixed4(noise, 1.0);
            }
            ENDCG
        }


        Pass {
            Name "ApplySSAO"

            CGPROGRAM
            float _Swipe;
            int _KernelSize;
            sampler2D _NoiseTex;
            sampler2D _CameraGBufferTexture2;

            float3 kernel[20];

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

            float3 CalculateNormal(float2 uv)
            {
                float depth = tex2D(_CameraDepthTexture, uv).r;
                float3 normal;
                
                // Get screen-space derivatives
                float ddx_depth = ddx(depth);
                float ddy_depth = ddy(depth);
                
                // Calculate approximate normals
                normal.x = -ddx_depth;
                normal.y = -ddy_depth;
                normal.z = 1.0;
                normal = normalize(normal);
                
                return normal;
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                uint2 pixelCoords = uint2(uint(_MainTex_TexelSize.z * IN.uv.x), uint(_MainTex_TexelSize.w * IN.uv.y));
                seed = hashi(pixelCoords.x + hashi(pixelCoords.y + 10000)); // +10000 da generira drugacije nasumicne brojeve nego noise texture

                // generiramo _KernelSize vektora u polusferi
                for (int i = 0; i < _KernelSize; i++){
                    kernel[i] = float3(0,0,0);
                    kernel[i].x = hash() * 2 - 1; // [-1, 1]
                    kernel[i].y = hash() * 2 - 1; // [-1, 1]
                    kernel[i].z = hash();         // [0, 1]

                    kernel[i] = normalize(kernel[i]);

                    //rasporedimo tocke tako da ih je vise blize ishodistu
                    float scale = float(i) / float(_KernelSize);
                    scale = lerp(0.1, 1.0, scale * scale);
                    kernel[i] *= scale;
                }

                float3 origin = IN.vertex;
                fixed3 normal = CalculateNormal(IN.uv);
                return fixed4(normal, 1);

                return col;
            }
            ENDCG
        }
    }
}
