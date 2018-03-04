Shader "Custom/HeatCameraEffect"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
        _Heatmap("Heat map", 2D) = "white" {}
        _Noise("Noise texture", 2D) = "white" {}
        _DistortStrength("Distort strength", float) = 1.0
        _DistortSpeed("Distort speed", float) = 1.0
        _Radius("Sample radius (in pixels)", float) = 10.0
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
            #include "UnityCG.cginc"
			
			// Properties
			uniform sampler2D _MainTex;
            uniform sampler2D _Heatmap;
            float4 _Heatmap_TexelSize; // (1/pixelHidth, 1/pixelHeight, width, height)
            uniform sampler2D _Noise;
            uniform float _DistortStrength;
            uniform float _DistortSpeed;
            uniform float _Radius;

            // returns 1 if withing _Radius of 'heat' pixel based on Heatmap
            // returns 0 otherwise
            float withinSampleRadius(float2 uv)
            {
                float heat = 0;

                // pixel location values for top-left pixel of each box A,B,C,D
				float2 start[4] = 
				{
					{-_Radius, -_Radius},
					{0, -_Radius},
					{-_Radius, 0},
					{0, 0} 
				};

                float2 pos;
                for(int i = 0; i < 4; i++)
				{
					for(int x = 0; x <= _Radius; x++)
					{
						for(int y = 0; y <= _Radius; y++)
						{
							// get relative pixel location in ABCD box
							// based on starting position + loop position
							pos = start[i] + float2(x,y);
							// convert relative pixel location
							// to image pixel location
							// based on image dimensions
							pos = (pos * _Heatmap_TexelSize.xy) + uv;
							// sample color
							float heatSample = tex2D(_Heatmap, pos).rgb;
							// update heat
                            heat = heat || heatSample;
						}
					}
				}

                return heat;
            }

			float4 frag(v2f_img input) : COLOR
			{
                //float heat = tex2D(_Heatmap, input.uv); // test- only sample local pixel
                float heat = withinSampleRadius(input.uv);

                float3 noise = tex2D(_Noise, input.uv).rgb;
                float2 samplePos = input.uv;
                samplePos.x += heat * cos(noise.x*_Time.x*_DistortSpeed) * _DistortStrength;
                samplePos.y += heat * sin(noise.y*_Time.x*_DistortSpeed) * _DistortStrength;

                // sample texture for color
				float4 base = tex2D(_MainTex, samplePos);

                //base = (1-heat)*base + float4(0, 0, 1, 1)*heat; // test

				return base;
			}

			ENDCG
		}
	}
}