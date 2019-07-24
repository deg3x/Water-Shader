Shader "Custom/waves"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_SpeedMainX("Displacement speed X (Main Texture)", Range(0.0, 10.0)) = 1.0
		_SpeedMainY("Displacement speed Y (Main Texture)", Range(0.0, 10.0)) = 1.0
		_HeightMap("Height Map", 2D) = "bump" {}
		_HeightDispl("Height Displacement", Range(0.0, 100.0)) = 1.0
		_SpeedHeightX("Displacement speed X (Height Map)", Range(0.0, 10.0)) = 1.0
		_SpeedHeightY("Displacement speed Y (Height Map)", Range(0.0, 10.0)) = 1.0
		_HeightMapTwo("Secondary Height Map", 2D) = "bump" {}
		_HeightDisplTwo("Height Displacement", Range(0.0, 100.0)) = 1.0
		_SpeedHeightXTwo("Displacement speed X (Height Map)", Range(0.0, 10.0)) = 1.0
		_SpeedHeightYTwo("Displacement speed Y (Height Map)", Range(0.0, 10.0)) = 1.0
		_WaveEnhancement("Wave enhancement factor", Range(0.0, 5.0)) = 2.0
    }
    SubShader
    {
        Tags 
		{ 
			"RenderType"="Transparent" 
		}
		Cull Off
		ZWrite On
		ZTest Always
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _HeightMap;
			float4 _HeightMap_ST;
			sampler2D _HeightMapTwo;
			float4 _HeightMapTwo_ST;
			float _SpeedMainX;
			float _SpeedMainY;
			float _HeightDispl;
			float _SpeedHeightX;
			float _SpeedHeightY;
			float _HeightDisplTwo;
			float _SpeedHeightXTwo;
			float _SpeedHeightYTwo;
			float _WaveEnhancement;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float3 direction = float3(_SpeedHeightX, 0.0, _SpeedHeightY);

				float4 huv = float4(TRANSFORM_TEX(v.uv, _HeightMap), 0, 0);

				huv.x = huv.x - (_Time.x * _SpeedHeightX);
				huv.y = huv.y - (_Time.x * _SpeedHeightY);

				float4 h = tex2Dlod(_HeightMap, huv);
				float factorA = (h.r + h.g + h.b) / 3.0;

				o.vertex.y -= lerp(-1, 1, smoothstep(0, 1, factorA)) * _HeightDispl;
				o.vertex.xyz += _WaveEnhancement * direction.xyz * saturate(lerp(-2, 2, factorA)) * factorA;

				float4 hhuv = float4(TRANSFORM_TEX(v.uv, _HeightMapTwo), 0, 0);
				
				hhuv.x = hhuv.x + (_Time.x * _SpeedHeightXTwo);
				hhuv.y = hhuv.y + (_Time.x * _SpeedHeightYTwo);

				float4 hh = tex2Dlod(_HeightMapTwo, hhuv);
				float factorB = (hh.r + hh.g + hh.b) / 3.0;

				o.vertex.y -= lerp(-1, 1, smoothstep(0, 1, factorB)) * _HeightDisplTwo;

				UNITY_TRANSFER_FOG(o, o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 displacedUV;
				displacedUV.x = i.uv.x - _Time.x * _SpeedMainX;
				displacedUV.y = i.uv.y - _Time.x * _SpeedMainY;

				fixed4 col = tex2D(_MainTex, displacedUV);

				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
            ENDCG
        }
    }
}
