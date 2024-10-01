Shader "Unlit/Chapter11_2_1"
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _HorizontalValue ("Horizontal Value",Float)=4
        _VerticalValue ("Vertical Value",Float)=4
        _SpeedValue ("Speed Value",Range(1,100))=4
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector" = "true"
        }
        LOD 100

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HorizontalValue;
            float _VerticalValue;
            float _SpeedValue;
            float3 _Color;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float time = floor(_Time.y*_SpeedValue);
                float row = floor(time / _HorizontalValue);
                float col = time - row * _HorizontalValue;
                float2 uv = i.uv + float2(col, -row);
                uv.x/=_HorizontalValue;
                uv.y/=_VerticalValue;
                fixed4 color = tex2D(_MainTex, uv);//必须是fixed4
                return color;

                
            }
            ENDCG
        }
    }
}