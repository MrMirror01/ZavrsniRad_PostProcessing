Shader "Hidden/SSAO2"
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
            sampler2D _CameraDepthTexture;

            float _Swipe;
            float _HemisphereRadius;
            float4x4 _ProjectionMatrix;
            float4x4 _InverseProjectionMatrix;

            float3 homogenize(float4 v) {
                return float3((1.0 / v.w) * v.xyz);
            }

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

            float3 CalculateNormals(float2 uv){
                float3 offset = float3(_MainTex_TexelSize.xy, 0.0);
	            float2 posCenter = uv;
	            float2 posNorth  = posCenter - offset.zy;
	            float2 posEast   = posCenter + offset.xz;

                float centerDepth = getDepth(posCenter);

	            float3 vertCenter = float3(posCenter - 0.5, 1) * centerDepth;
	            float3 vertNorth  = float3(posNorth - 0.5,  1) * getDepth(posNorth);
	            float3 vertEast   = float3(posEast - 0.5,   1) * getDepth(posEast);

	            return float4(normalize(cross(vertCenter - vertNorth, vertCenter - vertEast)) * 0.5 + 0.5, centerDepth);
            }

            // Computes one vector in the plane perpendicular to v
            float3 perpendicular(float3 v)
            {
                float3 av = abs(v);
                if (av.x < av.y){
                    if (av.x < av.z) return float3(0.0, -v.z, v.y);
                    else return float3(-v.y, v.x, 0.0);
                }  
                else{
                    if (av.y < av.z) return float3(-v.z, 0.0, v.x);
                    else return float3(-v.y, v.x, 0.0);
                }
            }

            // PCG random generator for 3 16-bit unsigned ints
            uint3 pcg3d16(uint3 v)
            {
            	v = v * 12829u + 47989u;
            
            	v.x += v.y * v.z;
            	v.y += v.z * v.x;
            	v.z += v.x * v.y;
            
            	v.x += v.y * v.z;
            	v.y += v.z * v.x;
            	v.z += v.x * v.y;
            
            	v ^= v >> 16u;
            	return v;
            }
            
            // Conversion function to move from floats to uints, and back
            float3 pcg3d16f(float3 v)
            {
            	uint3 uv = asuint(v);
            	uv ^= uv >> 16u; // Make the info be contained in the lower 16 bits
            
            	uint3 m = pcg3d16(uv);
            
            	return float3(m & 0xFFFF) / float3(0xFFFF.rrr);
            
            	// Construct a float with half-open range [0,1) using low 23 bits.
            	// All zeroes yields 0.0, all ones yields the next smallest representable value below 1.0.
            	// From https://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
            	const uint ieeeMantissa = 0x007FFFFFu; // binary32 mantissa bitmask
                const uint ieeeOne      = 0x3F800000u; // 1.0 in IEEE binary32
            
            	// Since the pcg3d16 function is only made to work for the lower 16 bits, we only use those
            	// by shifting them to be the highest of the 23
            	m <<= 7u;
                m &= ieeeMantissa;                     // Keep only mantissa bits (fractional part)
                m |= ieeeOne;                          // Add fractional part to 1.0
            
                float3 f = asuint(m);           // Range [1:2]
                return f - 1.0;                        // Range [0:1]
            }
            
            #define randf pcg3d16f

            static const float M_PI = 3.1415926538;

            float3 sampleHemisphereVolumeCosine(float idx, float2 uv)
            {
            	float3 r = randf(float3(uv.xy, idx));	
            	float3 ret;
            	r.x *= 2 * M_PI;
            	r.y = sqrt(r.y);
            	r.y = min(r.y, 0.99);
            	r.z = max(0.1, r.z);
            
            	ret.x = r.y * cos(r.x);
            	ret.y = r.y * sin(r.x);
            	ret.z = sqrt(max(0, 1 - dot(ret.xy, ret.xy)));
            	return ret * r.z;
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;
                
                float fragmentDepth = tex2D(_CameraDepthTexture, IN.uv).r;
                if (fragmentDepth <= 0.01) return col;

                // Normalized Device Coordinates (clip space)
                float4 ndc = float4(IN.uv.x * 2.0 - 1.0, IN.uv.y * 2.0 - 1.0, 
                                fragmentDepth * 2.0 - 1.0, 1.0);
                
                // Transform to view space
                float3 vs_pos = homogenize(mul(_InverseProjectionMatrix, ndc));

                float3 vs_normal = CalculateNormals(IN.uv) * 2 - 1;
                float3 vs_tangent = perpendicular(vs_normal);
                float3 vs_bitangent = cross(vs_normal, vs_tangent);

                float3x3 tbn = float3x3(vs_tangent, vs_bitangent, vs_normal); // local base
                
//--------------------------------------------------------------------------------------------------------
                int nof_samples = 20;
//--------------------------------------------------------------------------------------------------------

                int num_visible_samples = 0;
                int num_valid_samples = 0;
                for (int i = 0; i < nof_samples; i++) {
                    // Project an hemishere sample onto the local base
                    float3 s = mul(tbn, sampleHemisphereVolumeCosine(i, IN.uv));
                
                    // compute view-space position of sample
                    float3 vs_sample_position = vs_pos + s * _HemisphereRadius;
                
                    // compute the ndc-coords of the sample
                    float3 sample_coords_ndc = homogenize(mul(_ProjectionMatrix, float4(vs_sample_position, 1.0)));
                
                    // Sample the depth-buffer at a texture coord based on the ndc-coord of the sample
                    float blocker_depth = tex2D(_CameraDepthTexture, sample_coords_ndc.xy);
                
                    // Find the view-space coord of the blocker
                    float3 vs_blocker_pos = homogenize(mul(_InverseProjectionMatrix,
                            float4(sample_coords_ndc.xy, blocker_depth * 2.0 - 1.0, 1.0)));    
                
                    // If the blocker is futher away than the sample position, then
                    // the sample is valid and visible
                    if (vs_blocker_pos.z > vs_sample_position.z){
                        num_valid_samples++;
                        num_visible_samples++;
                    }
                    else if (length(vs_pos - vs_blocker_pos) <= _HemisphereRadius){
                        num_valid_samples++;
                    }
                
                    // Otherwise, if the sample is inside the hemisphere
                    // i.e. the distance from vs_pos to the blocker is smaller than the _HemisphereRadius
                    // then the sample is valid, but occluded
                }
                
                
                float visibility = 1.0;
                float hemisphericalVisibility = 1;
                
                if (num_valid_samples > 0)
                {
                    hemisphericalVisibility = float(num_visible_samples) / float(num_valid_samples);;
                }

                return 1 - hemisphericalVisibility;
            }
            ENDCG
        }
    }
}
