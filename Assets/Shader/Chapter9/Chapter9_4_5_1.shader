

Shader "ShaderLearn/Chapter8_3"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color("Diffuse Color",Color)=(1,1,1,1)
        _Cutoff ("Cut-Off Scale", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"
        }
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;
            fixed4 _Color;

            struct appdata
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed4 texColor = tex2D(_MainTex, i.uv);
                clip(texColor.a - _Cutoff);
                fixed3 albedo = texColor * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo;
                fixed3 diffuse = _LightColor0 * albedo * saturate(dot(worldNormal, worldLight));
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                fixed3 col = ambient + diffuse*atten;

                return fixed4(col, 1);
            }
            ENDCG
        }
    }
    Fallback "Transparent/Cutout/VertexLit"
}