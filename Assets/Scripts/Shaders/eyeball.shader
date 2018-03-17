Shader "Custom/Eyeball" 
{
	Properties
	{
		_Color("Color", Color) = (1, 1, 1, 1)
		_EdgeColor("Edge Color", Color) = (1, 1, 1, 1)
		_EdgeThickness("Silouette Dropoff Rate", float) = 1.0
        _SpecColor("Specular Highlight Color", Color) = (1, 1, 1, 1)
        _SpecCutoff("Spec Cutoff Value", Range(0.0, 1.0)) = 0.5
        _Spec1("Spec Tuning 1", float) = 1
        _Translation("Translation", vector) = (0,0,0,0)
        _Y1("Y1", float) = 1
        _DU("DU", vector) = (0,1,0,0)
        _ScaleDir("Scale Dir", vector) = (0,0,0,0)
        _ScaleAmt("Scale Amount", float) = 0
	}
	
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
		}

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			// Properties
			uniform float4	_Color;

			uniform float4	_EdgeColor;
			uniform float   _EdgeThickness;

            uniform float4 _SpecColor;
            uniform float _SpecCutoff;
            uniform float _Spec1;

            uniform float3 _Translation;
            uniform float _Y1;
            uniform float3 _DU;
            uniform float3 _ScaleDir;
            uniform float _ScaleAmt;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
                float3 lightDir : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
			};

            float sgn (float x)
            {
                if (x == 0)
                {
                    return 1;
                }
                return x / abs(x);
            }

			vertexOutput vert(vertexInput i)
			{
				vertexOutput output;

				// convert input to world space
				output.pos = UnityObjectToClipPos(i.vertex);
				output.normal = normalize(mul(float4(i.normal, 0.0), unity_WorldToObject).xyz);
				output.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, i.vertex).xyz);
                output.lightDir = -normalize(_WorldSpaceLightPos0.xyz);
				return output;
			}

			float4 frag(vertexOutput i) : COLOR 
			{
                // fresnel
				float edgeFactor = abs(dot(i.viewDir, i.normal));
				float oneMinusEdge = 1.0 - edgeFactor;
				float3 rgb = (_Color.rgb * edgeFactor) + (_EdgeColor * oneMinusEdge);
				rgb = min(float3(1, 1, 1), rgb);
				float opacity = min(1.0, _Color.a / edgeFactor);
				opacity = pow(opacity, _EdgeThickness);

                // basic half vector
                float3 h = normalize(i.viewDir - i.lightDir);

                /*// translate
                h = normalize(h + _Translation); 
 
                // scale in a direction
                float3 hs = h - _ScaleAmt * dot(h, _ScaleDir) * _ScaleDir;
                h = normalize(hs);

                // split
                float3 dh = h - _Y1 * sgn(dot(h, _DU)) * _DU;
                h = normalize(dh);*/

                // stylized blinn specular highlights
                float spec = dot(i.normal, h) >= _SpecCutoff;
                float spec2 = dot(i.normal, normalize(h + _Translation)) >= _SpecCutoff;
                float4 specColor = float4(spec*_SpecColor.rgb + spec2*_SpecColor.rgb, spec + spec2);

				float4 output = float4(rgb, opacity) + specColor;
				return output;
			}

			ENDCG
		}
	}

}