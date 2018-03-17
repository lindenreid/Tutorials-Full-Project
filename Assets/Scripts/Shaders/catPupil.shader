Shader "Custom/CatPupil"
{
	Properties
	{
        _PupilColor("Pupil Color", Color) = (1, 1, 1, 1)
        _PupilRadius("Radius", float) = 1
        _OuterColor("Outer Color", Color) = (1, 1, 1, 1)
        _OuterRadius("Outer Radiius", float) = 1
        _EyeDist("Eye Open-ness", Range(0, 0.18)) = 0.0
	}
  
	SubShader
	{ 
		Pass
		{
            Cull Front 

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			// Properties
			uniform float4 _PupilColor;
            uniform float4 _OuterColor;
            uniform float _PupilRadius;
            uniform float _OuterRadius;
            uniform float _EyeDist;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 texCoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float3 texCoord : TEXCOORD0;
			};

            float sdf_circle(float2 texCoord, float2 center, float radius)
            {
                // get distance from pixel to center of circle
                float2 dist = distance(texCoord, center);
                // returns positive if within radius; negative if not
                return dist - radius;
            }

            float intersection(float d1, float d2)
            {
                return max (d1, d2) < 0; 
            }

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				output.pos = UnityObjectToClipPos(input.vertex);
				output.texCoord = input.texCoord;
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
                float2 _Center = float2(0.5, 0.5);
                float2 xy = input.texCoord.xy;
                float2 gap = float2(_EyeDist, 0);
                float d1 = sdf_circle(xy, _Center + gap, _PupilRadius);
                float d2 = sdf_circle(xy, _Center - gap, _PupilRadius);
                float o1 = sdf_circle(xy, _Center + gap, _OuterRadius);
                float o2 = sdf_circle(xy, _Center - gap, _OuterRadius);

                float i = intersection(d1, d2);
                float o = intersection(o1, o2);

                if (o == false) 
                {
                    clip(-1.0);
                } 
                else if (i == true)
                {
                    return _PupilColor;
                }
                return _OuterColor;
			}

			ENDCG
		}
	}
}