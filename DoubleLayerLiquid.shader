Shader "DoubleLayerLiquid"//双层液体Shader
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Header(No.0)]
        _Value ("液体填充值", Range(0,1)) = 0.0
        _Color("液体颜色",Color) = (1,1,1,1)
        _AlphaScale("液体透明度",Range(0,1)) = 1
        
        [Header(No.1)]
        _Value1 ("液体填充值1", Range(0,1)) = 0.0
        _Color1("液体颜色1",Color) = (1,1,1,1)
        _AlphaScale1("液体透明度1",Range(0,1)) = 1
    }
 
    SubShader
    {   
        Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

    
        Pass
        {
            Name "BackRender"

            Tags { "LightMode" = "ForwardBase" }
            
            Zwrite Off//关闭深度写入
            Cull Front // 剔除正面
            Blend SrcAlpha OneMinusSrcAlpha


            CGPROGRAM
    
    
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                //float3 normal : NORMAL; 
                float2 uv : TEXCOORD0;
            };
    
            struct v2f
            {
                float4 pos : SV_POSITION;
                //float3 worldNormal : TEXCOORD0;    
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };
    
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Value,_Value1;
            float4 _Color, _Color1;
            fixed _AlphaScale,_AlphaScale1;
    
            v2f vert (appdata v)
            {
                v2f o;
    
                o.pos = UnityObjectToClipPos(v.vertex);
                //o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul (unity_ObjectToWorld, v.vertex.xyz);  
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);   

                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col;
                fixed alphaScale;

                //fixed3 worldNormal = normalize(i.worldNormal);
                //fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex,i.uv);
            
                //阀值以上剔除
                if(i.worldPos.y > _Value + _Value1)
                {
                    clip(-1);
                }
                else if(i.worldPos.y <=_Value)
                {
                    col = _Color;
                    alphaScale = _AlphaScale;
                }
                else if(i.worldPos.y >_Value && i.worldPos.y <= _Value1)
                {
                    col = _Color1;
                    alphaScale = _AlphaScale1;
                }

                fixed3 albedo = texColor.rgb*col.rgb;

                //fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                //fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));

                //fixed4 finalCol = fixed4(ambient + diffuse,texColor.a*alphaScale);
                fixed4 finalCol = fixed4(albedo,texColor.a*col.a*alphaScale);
                return finalCol;

            }
            ENDCG
        }

        Pass
        {
            Name "FrontRender"
            Tags { "LightMode" = "ForwardBase" }

            Zwrite Off//关闭深度写入
            Cull Back //剔除背面
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
    
    
            #pragma vertex vert
            #pragma fragment frag
            //#include "Lighting.cginc"
            #include "UnityCG.cginc"
    
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL; 
                float2 uv : TEXCOORD0;
            };
    
            struct v2f
            {
                float4 pos : SV_POSITION;
                //float3 worldNormal : TEXCOORD0;    
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };
    
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Value,_Value1;
            float4 _Color, _Color1;
            fixed _AlphaScale,_AlphaScale1;
    
            v2f vert (appdata v)
            {
                v2f o;
    
                o.pos = UnityObjectToClipPos(v.vertex);
                //o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul (unity_ObjectToWorld, v.vertex.xyz);  
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);   

                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col;
                fixed alphaScale;
                fixed4 finalCol;

                //fixed3 worldNormal = normalize(i.worldNormal);
                //fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex,i.uv);
            
                //阀值以上剔除
                if(i.worldPos.y > _Value + _Value1)
                {
                    clip(-1);
                }
                else if(i.worldPos.y <=_Value)
                {
                    col = _Color;
                    alphaScale = _AlphaScale;
                }
                else if(i.worldPos.y >_Value && i.worldPos.y <= _Value1)
                {
                    col = _Color1;
                    alphaScale = _AlphaScale1;
                }

                fixed3 albedo = texColor.rgb*col.rgb;

                //fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                //fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));

                //fixed4 finalCol = fixed4(ambient + diffuse,texColor.a*alphaScale);
                finalCol = fixed4(albedo,texColor.a*col.a*alphaScale);

                return finalCol;
            }
            ENDCG
        }
 
    }

    FallBack "Transparent/VertexLit"
}