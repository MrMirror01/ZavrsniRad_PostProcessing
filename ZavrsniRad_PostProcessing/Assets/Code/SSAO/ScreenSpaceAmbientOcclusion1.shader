Shader "Hidden/ScreenSpaceAmbientOcclusion1"
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
            float _Radius;
            float4x4 _InverseProjectionMat;
            sampler2D _NoiseTex;
            float _TanHalfFov;
            float _Aspect;

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

            float3 CalculateNormals(float2 uv) {
                //ocitamo udaljenost tri piksela od kamere
                float3 offset = float3(_MainTex_TexelSize.xy, 0.0);
	            float2 posCenter = uv;
	            float2 posUp = posCenter - offset.zy;
	            float2 posRight = posCenter + offset.xz;

                //izracunamo pozicije ta tri piksela u odnosu na kameru
                float centerDepth = getDepth(posCenter);
	            float3 vertCenter = float3(posCenter - 0.5, 1) * centerDepth;
	            float3 vertUp  = float3(posUp - 0.5,  1) * getDepth(posUp);
	            float3 vertRight   = float3(posRight - 0.5,   1) * getDepth(posRight);

                //uz pomoc vektorkog umnoska vektora koji povezuju te piksele izracunamo normalu
	            return normalize(cross(vertCenter - vertUp, vertCenter - vertRight)) * 0.5 + 0.5;
            }

            float3 PositionFromDepth(float2 uv)
            {
                float2 normalDeviceCoords = uv * 2 - 1; //kao uv ali u intervalu [-1, 1]
                float3 viewRay = float3(
                    normalDeviceCoords.x * _TanHalfFov * _Aspect,
                    normalDeviceCoords.y * _TanHalfFov,
                    1.0
                );

                return viewRay * getDepth(uv);

                /*
                // Get the depth value for this pixel
                float z = tex2D(_CameraDepthTexture, uv); //LINEAR depth
                //??????????????????????????????????????????????????????????????????????????????????????????????????????????????
                //komentar na blogu???????????????????????????????????????????????????
                //????????????????????????????????????????????????????????????????????????????????????????????????????
                // Get x/w and y/w from the viewport position
                float x = uv.x * 2 - 1;
                float y = uv.y * 2 - 1;
                float4 vProjectedPos = float4(x, y, z, 1.0);
                // Transform by the inverse projection matrix
                float4 vPositionVS = mul(_InverseProjectionMat, vProjectedPos);  
                // Divide by w to get the view-space position
                return vPositionVS.xyz / vPositionVS.w;
                */
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                uint2 pixelCoords = uint2(_MainTex_TexelSize.zw * IN.uv);
                seed = 0; // +10000 da generira drugacije nasumicne brojeve nego noise texture

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

                float3 origin = PositionFromDepth(IN.uv);
                fixed3 normal = CalculateNormals(IN.uv) * 2 - 1;
                normal = -normalize(normal);

                float3 randomRotation = tex2D(_NoiseTex, IN.uv * _MainTex_TexelSize.zw / 4) * 2 - 1;
                float3 tangent = normalize(randomRotation - normal * dot(randomRotation, normal));
                float3 bitangent = cross(normal, tangent);
                float3x3 tbn = float3x3(bitangent, tangent, normal);

                // izracunamo poziciju uzorka
                float3 sample = mul(tbn, kernel[0]);
                sample = sample * _Radius + origin;
                  
                // projektiramo poziciju uzorka
                float4 offset = float4(origin, 1.0);
                float4x4 pmat = UNITY_MATRIX_P;
                pmat[1][1] *= -1;
                float near = _ProjectionParams.y;
                float far = _ProjectionParams.z;
                pmat[2][2] = (far + near) / (near - far);
                pmat[2][3] *= 2;
                offset = mul(UNITY_MATRIX_P, offset);
                offset.xy /= offset.w;

                return fixed4(offset.xy * 100, 0, 1);

                float occlusion = 0.0;
                for (int i = 0; i < _KernelSize; i++) {
                    // izracunamo poziciju uzorka
                    float3 sample = mul(tbn, kernel[i]);
                    sample = sample * _Radius + origin;
                      
                    // projektiramo poziciju uzorka
                    float4 offset = float4(sample, 1.0);
                    float4x4 pmat = UNITY_MATRIX_P;
                    pmat[1][1] *= -1;
                    float near = _ProjectionParams.y;
                    float far = _ProjectionParams.z;
                    pmat[2][2] = (far + near) / (near - far);
                    pmat[2][3] *= 2;
                    offset = mul(pmat, offset);
                    offset.xy /= offset.w;
                    offset.xy = offset.xy * 0.032 + 0.5;
                      
                    // izcitamo udaljenost
                    float sampleDepth = getDepth(offset.xy);
                      
                    // range check & accumulate:
                    float rangeCheck = abs(origin.z - sampleDepth) < _Radius ? 1.0 : 0.0;
                    occlusion += (sampleDepth <= sample.z ? 1.0 : 0.0) * rangeCheck;
                }

                occlusion = 1 - (occlusion / _KernelSize);
                return fixed4(occlusion * col.rgb, 1);
            }
            ENDCG
        }
    }
}
