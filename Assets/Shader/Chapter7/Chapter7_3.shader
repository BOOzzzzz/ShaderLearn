Shader "ShaderLearn/Chapter7_3"
{
    Properties
    {
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _Color("Diffuse Color",Color)=(1,1,1,1)
        _Specular("Specular Color",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,256))=20
    }
    SubShader
    {

        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            sampler2D _RampTex;
            float4 _RampTex_ST;
            fixed4 _Color;
            fixed4 _Specular;
            float _Gloss;

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
                float3 worldpPos:TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord * _RampTex_ST.xy + _RampTex_ST.zw;
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                o.worldpPos=mul(unity_ObjectToWorld,v.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldLightDir=UnityWorldSpaceLightDir(i.worldpPos);
                fixed3 worldViewDir=UnityWorldSpaceViewDir(i.worldpPos);
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                fixed halfLambert=0.5*dot(worldLightDir,i.worldNormal)+0.5;
                fixed3 diffuseColor=tex2D(_RampTex,fixed2(halfLambert,halfLambert))*_Color;
                fixed3 diffuse = _LightColor0 * diffuseColor;
                fixed3 halfDir = normalize(worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0 * _Specular * pow(saturate(dot(i.worldNormal, halfDir)), _Gloss);
                fixed3 col = ambient + diffuse + specular;

                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}