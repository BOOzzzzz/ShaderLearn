Shader "Unlit/Chapter10_1_5"
{
    Properties
    {
        _MainTex("Main Texture",2d)="white"{}
        _BumpMap("Normal Map",2d)="bump"{}
        _CubeMap("Cube Map",Cube)="_Skybox"{}
        _Distortion ("Distortion", Range(0, 100)) = 10
        _RefractAmount ("Refract Amount", Range(0.0, 1.0)) = 1.0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }

        GrabPass
        {
            "_RefractionTex"
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

            

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            samplerCUBE _Cubemap;
            float _Distortion;
            fixed _RefractAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv:TEXCOORD0;
                float4 scrPos:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
                float3 worldNormal:TEXCOORD3;
                float3 worldTangent:TEXCOORD4;
                float3 worldBinormal:TEXCOORD5;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.scrPos = ComputeGrabScreenPos(o.pos);

                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BumpMap);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                half3x3 TBN = half3x3(i.worldTangent, i.worldBinormal, i.worldNormal);
                half3 worldView=normalize(UnityWorldSpaceViewDir(i.worldPos));

                float2 offset = tangentNormal.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
				fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;
                
                half3 worldNormal = normalize(mul(tangentNormal,TBN));
                half3 relectDir=reflect(-worldView,worldNormal);
                half3 mainTex = tex2D(_MainTex,i.uv.xy);
                half3 reflectCol=texCUBE(_Cubemap,relectDir).rgb*mainTex.rgb;
                
                fixed3 finalColor = reflectCol * (1 - _RefractAmount) + _RefractAmount * refrCol;
                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}