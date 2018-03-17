Shader "Custom/CatEye"
{
	Properties
	{
		_Color("Iris Color", Color) = (1, 1, 1, 1)
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
			uniform float4 _Color;

			struct vertexInput
			{
				float4 vertex : POSITION;
                float3 normal : NORMAL;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				output.pos = UnityObjectToClipPos(input.vertex);
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
                return _Color;
			}

			ENDCG
		}
	}
}