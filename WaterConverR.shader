// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/WaterConverR" {
	Properties{
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "white" {}
	    _Value("Value",float) = 0
		//_Center("CenterOfBall",float) = 0
		_Radius("Radius",float) = 1
		_ConcaveValue("ConvaveValue",float) = 0
		//_ValueSecond("ValueSecond",float) = 0
	}
		SubShader{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

		Pass{
		Tags{ "LightMode" = "ForwardBase" }
		ZWrite Off
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"
#define PI 3.14159	
		//float _Center;
		float _Radius;
	fixed4 _Color;
	sampler2D _MainTex;
	float4 _MainTex_ST;
	float _Value;
	float _ConcaveValue;
	//float _ValueSecond;
	struct a2v {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 texcoord : TEXCOORD0;
	};

	struct v2f {
		float4 pos : SV_POSITION;
		float3 worldNormal : TEXCOORD0;
		float3 worldPos : TEXCOORD1;
		float2 uv : TEXCOORD2;
		float4 Col:Color;
	};

	//曲线的公式
	float3 getBezierPt(float3 p0,float3 p1,float3 p2,float3 p3, float t)
	{

		return p0*(1 - 3 * t + 3 * t*t - t*t*t) + p1*(3 * t-6*t*t + 3 * t*t*t) + p2* (3 * t*t-3*t*t*t) + p3*t*t*t;
	}

	v2f vert(a2v v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);

		o.worldNormal = UnityObjectToWorldNormal(v.normal);

		o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

		return o;
	}
	float4x4 obj2world;
	fixed4 frag(v2f i) : SV_Target{
		float4 f4 = { 0,0,0,1 };
	//	float4 center = {0,_Value+_Center,0,1};

	//	float4 center = { 0,_Value + _ConcaveValue,0,1 };
	float4 LocalPos = mul(unity_ObjectToWorld,f4);

	fixed3 worldNormal = normalize(i.worldNormal);


	float3 I = i.worldPos.xyz - _WorldSpaceCameraPos.xyz;
	float3 f3 = LocalPos.xyz - _WorldSpaceCameraPos.xyz;
	f3.y = 0;

	float3 INormal = normalize(f3);
	float3  Xaxis = cross(INormal, float3(0, 1, 0));
	float3 a1 = Xaxis* _Radius;
	float3 a2 =a1- float3(0, _ConcaveValue, 0);
	float3 a3 = Xaxis* _Radius*-1;
	float3 a4 =a3 -float3(0, _ConcaveValue, 0);



	//   f2 = mul(UNITY_MATRIX_VP, f2);


	float3 f5 = i.worldPos - LocalPos.xyz;
     

	//	 float2 f2 ={LocalPos.y+_Value+_Center,LocalPos.z};

	if (i.worldPos.y>LocalPos.y + _Value)
	{

		clip(-1);
	}
	//else if(_Value>_ConcaveValue&& distance(i.worldPos.yz,f2)<_Radius)
	else if (_Value>_ConcaveValue && dot(worldNormal, I)< 0)
	{

		/*float len = dot(I.xz, INormal);
		len = length(I.xz - INormal*len);

		len = len / _Radius;

		float con = _ConcaveValue*cos(PI*0.5*len);

		con = _Value - con;*/
		float angle = dot(normalize(Xaxis.xz), normalize(f5.xz));
		angle = (angle - 1)*(-0.5);
		float3 f6 = getBezierPt(a1, a2, a4, a3, angle);
		clip(_Value+f6.y-f5.y);

		/*if ((f5.y > con) && (i.worldPos.y>LocalPos.y + _ValueSecond))
		{
			clip(-1);
		}*/








	}

	fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

	fixed4 texColor = tex2D(_MainTex, i.uv);

	fixed3 albedo = texColor.rgb * _Color.rgb;
	/*
	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

	fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));*/
	fixed4 col = fixed4(albedo, texColor.a * _Color.a);
	return col;
	}

		ENDCG
	}
	}
		FallBack "Transparent/VertexLit"
}
