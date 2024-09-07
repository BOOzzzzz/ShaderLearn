Shader "Unlit/Chapter10_1_4"
{
    Properties
    {
        _Color("Base Color",Color)=(1,1,1,1)
        _RefractionColor("Reflection Color",Color)=(1,1,1,1)
        _RefractionAmount("Reflection Amount",Range(0,1))=0
        _RefractionRatio("Refraction Radio",Range(0.1,1))=0.6
        _CubeMap("Cube Map",Cube)="_Skybox"{}
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
            CGPROGRAM
			#pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include  "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                SHADOW_COORDS(2)
            };

            float4 _Color;
            float4 _RefractionColor;
            float _RefractionAmount;
            float _RefractionRatio;
            samplerCUBE _CubeMap;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldView = UnityWorldSpaceViewDir(i.worldPos);
                fixed3 refractionDir = refract(-normalize(worldView), worldNormal,_RefractionRatio);
                fixed4 refractionColor = texCUBE(_CubeMap, refractionDir) * _RefractionColor;
                fixed3 diffuseColor = _Color * _LightColor0.rgb * saturate(dot(worldNormal, worldLightDir));
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 color = ambient + lerp(diffuseColor, refractionColor, _RefractionAmount) * atten;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}