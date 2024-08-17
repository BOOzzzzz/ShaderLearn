// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderLearn/Chapter9_4"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
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
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert(a2v v)
            {
                v2f o;
                // Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);

                // Transform the normal from object space to world space
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

                // Transform the vertex from object spacet to world space
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(o)

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                // Compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

                // Get the view direction in world space
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                // Get the half direction in world space
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                // Compute specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                fixed shadow = SHADOW_ATTENUATION(i);
                fixed attend = 1;

                return fixed4(ambient + (diffuse + specular) * attend * shadow, 1.0);
            }
            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode"="ForwardAdd"
            }

            Blend One One

            CGPROGRAM
            #pragma multi_compile_fwdadd

            #pragma vertex vert
            #pragma fragment frag

            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                // Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);

                // Transform the normal from object space to world space
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

                // Transform the vertex from object spacet to world space
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;


                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir0;
                #ifdef USING_DIRECTIONAL_LIGHT
                worldLightDir0 = _WorldSpaceLightPos0.xyz;
                #else
                worldLightDir0 = _WorldSpaceLightPos0.xyz-i.worldPos.xyz;
                #endif

                // Compute diffuse term
                fixed3 worldLightDir = normalize(worldLightDir0);

                // Compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

                // Get the view direction in world space
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                // Get the half direction in world space
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                // Compute specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                #ifdef USING_DIRECTIONAL_LIGHT
                fixed atten = 1.0;
                #else
                #if defined (POINT)
				        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #elif defined (SPOT)
				        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
				        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #else
				        fixed atten = 1.0;
                #endif
                #endif

                return fixed4((diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}