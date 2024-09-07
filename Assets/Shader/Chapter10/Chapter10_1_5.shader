Shader "Unlit/Chapter10_1_5"
{
    Properties
    {
        _Color("Base Color",Color)=(1,1,1,1)
        _FresnelScale("FresnelScale",Range(0,1))=0
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
                float3 worldView:TEXCOORD2;
                float3 worldRel:TEXCOORD3;
                SHADOW_COORDS(4)
            };

            float4 _Color;
            float _FresnelScale;
            samplerCUBE _CubeMap;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldView=UnityWorldSpaceViewDir(o.worldPos);
                o.worldRel=reflect(-o.worldView,o.worldNormal);
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldView = normalize(i.worldView);
                fixed4 reflectionColor = texCUBE(_CubeMap, i.worldRel);
                fixed3 diffuseColor = _Color * _LightColor0.rgb * saturate(dot(worldNormal, worldLightDir));
                fixed fresnelScale=_FresnelScale+(1-_FresnelScale)*pow(1-dot(worldView,worldNormal),5);
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 color = ambient + (diffuseColor+reflectionColor*fresnelScale) * atten;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}