Shader "Hidden/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    CGINCLUDE
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
        float _Swipe;
        sampler2D _SourceTex;
        half4 _Filter; // {treshold, treshold - knee, 2 * knee, 0.25 / knee}
                       //where knee = treshold * softTreshold
        half _Intensity;

        half3 Sample (float2 uv) {
		    return tex2D(_MainTex, uv).rgb;
		}

        half3 SampleBox (float2 uv, float delta) {
            // o = {-texelWidth, -texelHeight, texelWidth, texelHeight} * delta
		    float4 o = _MainTex_TexelSize.xyxy * float4(-1, -1, 1, 1) * delta;
		    half3 s =
		        Sample(uv + o.xy) + Sample(uv + o.zy) +
		        Sample(uv + o.xw) + Sample(uv + o.zw);
		    return s * 0.25f;
		}

        half3 Prefilter (half3 c) {
            //the brightness of a color is defined as its brightest component
			half brightness = max(c.r, max(c.g, c.b));

            //soft knee 
			half soft = brightness - _Filter.y;
			soft = clamp(soft, 0, _Filter.z);
			soft = soft * soft * _Filter.w;

            //determines how much a color will influence the bloom based on its brightness and the treshold
			half contribution = max(soft, brightness - _Filter.x);
			contribution /= max(brightness, 0.00001);
			return c * contribution;
		}
    ENDCG

    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        //first downsample with prefilter pass (0)
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            half4 frag (v2f IN) : SV_Target
            {
                return half4(Prefilter(SampleBox(IN.uv, 1)), 1);
            }
            ENDCG
        }

        //downsample pass (1)
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            half4 frag (v2f IN) : SV_Target
            {
                return half4(SampleBox(IN.uv, 1), 1);
            }
            ENDCG
        }

        //upsample pass (2)
        Pass
        {
            //additive blending -> the new value will be added instead of replaceing the old value
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            half4 frag (v2f IN) : SV_Target
            {
                return half4(SampleBox(IN.uv, 0.5), 1);
            }
            ENDCG
        }

        //apply bloom to original image pass (3)
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            half4 frag (v2f IN) : SV_Target
            {
                //sampleing from source texture for 'custom' additive blending
                half4 col = tex2D(_SourceTex, IN.uv);
                if (_Swipe < IN.uv.x) return col;

                col.rgb += _Intensity * SampleBox(IN.uv, 0.5);
                //float lum = 0.2126 * col.r + 0.7152 * col.g + 0.0722 * col.b; //luminance of pixel
                //half3 tonemappedLuminance = lum * (1 + (lum / (_WhitePoint * _WhitePoint))) / (1 + lum); //tone mapping

                return half4(col.rgb/* * (tonemappedLuminance / lum)*/, 1);
            }
            ENDCG
        }

        //debug pass - only bloom (4)
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            half4 frag (v2f IN) : SV_Target
            {
                //sampleing from source texture for 'custom' additive blending
                half4 col = half4(_Intensity * SampleBox(IN.uv, 0.5), 1);
                return col;
            }
            ENDCG
        }
    }
}