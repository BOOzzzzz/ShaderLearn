Shader "Unlit/Chapter10_1_5"
{
    Properties
    {
        _MainTexture("Main Texture",2d)="white"{}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            Cull Off
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include  "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            sampler2D _MainTexture;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 color = tex2D(_MainTexture, i.uv);
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}