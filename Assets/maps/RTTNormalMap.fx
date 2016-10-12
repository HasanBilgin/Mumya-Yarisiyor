//////////////////////////////////////////////////////////////////////////////////////
//simple Duffuse bump 
//To be used with the RTT tool and the new Normal Mapping technology
//
//This was updated by the guys at Rad Tools to fix some lighting problems in the original
//Added DX8 level support.
//Cleaned up code
////////////////////////////////////////////////////////////////////////////////////////

float4x4 worldMatrix : 		World;	// World or Model matrix
float4x4 WorldIMatrix : 	WorldI;	// World Inverse or Model Inverse matrix
float4x4 mvpMatrix : 		WorldViewProj;	// Model*View*Projection
float4x4 worldViewMatrix : 	WorldView;
float4x4 viewInverseMatrix :	ViewI;

// tweakables

texture diffuseTexture : DiffuseMap< 
	string name = "seafloor.dds"; 
	string UIName = "Diffuse Map";
	int Texcoord = 0;
	int MapChannel = 1;	
	>;
	
texture TangentMap : NormalMap < 
	string name = "NMP_Ripples2_512.dds"; 
	string UIName = "Tangent Space";
	int Texcoord = 0;
	int MapChannel = 1;	
	>;
	
texture WorldMap : NormalMap < 
//	string name = "NMP_Ripples2_512.dds"; 
	string UIName = "World Space";
	int Texcoord = 0;
	int MapChannel = 1;	
	>;
texture LocalMap : NormalMap < 
//	string name = "NMP_Ripples2_512.dds"; 
	string UIName = "Local Space";
	int Texcoord = 0;
	int MapChannel = 1;	
	>;	

float4 ambientColor : Ambient
<
> = { 0.1, 0.1, 0.1, 1.0};


float bumpHeight
<
    string UIType = "FloatSpinner";
	string UIName = "Bump Height";
	float UIMin = 0.0f;
	float UIMax = 2.0f;	
> = { 1.5};


float4 lightDir : Direction <  
	string UIName = "Light Direction"; 
	string Object = "TargetLight";
	int RefID = 0;
	> = {-0.577, -0.577, 0.577,1.0};


struct a2v {
	float4 Position : POSITION; //in object space
	float3 Normal : NORMAL; //in object space
	float2 TexCoord : TEXCOORD0;
	float3 T : TANGENT; //in object space
	float3 B : BINORMAL; //in object space
};

struct v2f {
	float4 Position : POSITION; //in projection space
	float2 TexCoord0 : TEXCOORD0;
	float2 TexCoord1 : TEXCOORD1;
	float3 LightVector : TEXCOORD2;
};

struct f2fb {
	float4 col : COLOR;
};

v2f DiffuseBumpVS(a2v IN,
		uniform float4x4 WorldViewProj,
        	uniform float4x4 WorldIMatrix,
                uniform float4x4 WorldMatrix,
		uniform float3 LightDir)
{
	v2f OUT;

	// pass texture coordinates for fetching the diffuse map
	OUT.TexCoord0.xy = IN.TexCoord.xy;

	// pass texture coordinates for fetching the normal map
	OUT.TexCoord1.xy = IN.TexCoord.xy;

	// compute the 3x3 tranform from tangent space to object space
	float3x3 objToTangentSpace;
	objToTangentSpace[0] = IN.B;
	objToTangentSpace[1] = IN.T;
	objToTangentSpace[2] = IN.Normal;

	// transform normal from object space to tangent space and pass it as a color
	//OUT.Normal.xyz = 0.5 * mul(IN.Normal,objToTangentSpace) + 0.5.xxx;

    	float4 objectLightDir = mul(LightDir,WorldIMatrix);
	float4 vertnormLightVec = normalize(objectLightDir);
	// transform light vector from object space to tangent space and pass it as a color 
	OUT.LightVector.xyz = 0.5 * mul(objToTangentSpace,vertnormLightVec.xyz ) + 0.5.xxx;
	// transform position to projection space
	OUT.Position = mul(IN.Position,WorldViewProj).xyzw;

	return OUT;
}

v2f DiffuseWBumpVS(a2v IN,
		uniform float4x4 WorldViewProj,
        	uniform float4x4 WorldIMatrix,
                uniform float4x4 WorldMatrix,
		uniform float3 LightDir)
{
	v2f OUT;

	// pass texture coordinates for fetching the diffuse map
	OUT.TexCoord0.xy = IN.TexCoord.xy;

	// pass texture coordinates for fetching the normal map
	OUT.TexCoord1.xy = IN.TexCoord.xy;
	
	//light vector in world space
	float4 objectLightDir = float4(LightDir,1.0);
	float4 vertnormLightVec = normalize(objectLightDir);
	
	OUT.LightVector.xyz = 0.5 * vertnormLightVec + 0.5.xxx;
	// transform position to projection space
	OUT.Position = mul(IN.Position,WorldViewProj).xyzw;

	return OUT;
}

v2f DiffuseLBumpVS(a2v IN,
		uniform float4x4 WorldViewProj,
        	uniform float4x4 WorldIMatrix,
                uniform float4x4 WorldMatrix,
		uniform float3 LightDir)
{
	v2f OUT;

	// pass texture coordinates for fetching the diffuse map
	OUT.TexCoord0.xy = IN.TexCoord.xy;

	// pass texture coordinates for fetching the normal map
	OUT.TexCoord1.xy = IN.TexCoord.xy;


    	float4 objectLightDir = mul(LightDir,WorldIMatrix);
	float4 vertnormLightVec = normalize(objectLightDir);

	
	OUT.LightVector.xyz = 0.5 * vertnormLightVec + 0.5.xxx;
	// transform position to projection space
	OUT.Position = mul(IN.Position,WorldViewProj).xyzw;

	return OUT;
}

// nothing fancy here - just removing incompatible code

f2fb DiffuseBumpPS1(v2f IN,
		uniform sampler2D DiffuseMap,
		uniform sampler2D NormalMap,
              	uniform float4 bumpHeight) 
{
	f2fb OUT;

	//fetch base color
        float2 Temp = IN.TexCoord0;
	float4 color = tex2D(DiffuseMap,Temp);

	//fetch bump normal
	
	float4 bumpNormal = (2 * (tex2D(NormalMap,IN.TexCoord1)-0.5));
	bumpNormal.xy = bumpNormal.xy * bumpHeight.xx;

	//expand iterated light vector to [-1,1]
	float3 lightVector = 2 * (IN.LightVector - 0.5 );

	//compute final color (diffuse + ambient)
	float4 bump = dot(bumpNormal.xyz,lightVector.xyz);
	OUT.col = (color *bump) + 0.1 ;
	OUT.col.a = 1.0;
	
	return OUT;
}

f2fb DiffuseBumpPS2(v2f IN,
		uniform sampler2D DiffuseMap,
		uniform sampler2D NormalMap,
              	uniform float4 bumpHeight) 
{
	f2fb OUT;

	//fetch base color
        float2 Temp = IN.TexCoord0;
	float4 color = tex2D(DiffuseMap,Temp);

	//fetch bump normal
	
	float4 bumpNormal = (2 * (tex2D(NormalMap,IN.TexCoord1)-0.5));
	bumpNormal.xy = bumpNormal.xy * bumpHeight.xx;
	bumpNormal = normalize(bumpNormal);	

	//expand iterated light vector to [-1,1]
	float3 lightVector = 2 * (IN.LightVector - 0.5 );
	lightVector = normalize(lightVector);

	//compute final color (diffuse + ambient)
	float4 bump = dot(bumpNormal.xyz,lightVector.xyz);
	OUT.col = (color *bump) + 0.1 ;
	OUT.col.a = 1.0;

	return OUT;
}


sampler2D diffuseSampler = sampler_state
{
	Texture = <diffuseTexture>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

sampler2D tangentSampler = sampler_state 
{
	Texture = <TangentMap>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

sampler2D worldSampler = sampler_state 
{
	Texture = <WorldMap>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};
sampler2D localSampler = sampler_state 
{
	Texture = <LocalMap>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
};

//////// techniques ////////////////////////////



technique TangentSpace_2_0
{

	pass p0
	{
		ZEnable = true;
		ZWriteEnable = true;
		CullMode = None;
		VertexShader = compile vs_1_1 DiffuseBumpVS(mvpMatrix,WorldIMatrix,worldMatrix,lightDir);
        	PixelShader = compile ps_2_0 DiffuseBumpPS2(diffuseSampler,tangentSampler,bumpHeight);
	}
}

technique WorldSpace_2_0
{

	pass p0
	{
		ZEnable = true;
		ZWriteEnable = true;
		CullMode = None;
		VertexShader = compile vs_1_1 DiffuseWBumpVS(mvpMatrix,WorldIMatrix,worldMatrix,lightDir);
        	PixelShader = compile ps_2_0 DiffuseBumpPS2(diffuseSampler,worldSampler,bumpHeight);
	}
}

technique LocalSpace_2_0
{

	pass p0
	{
		ZEnable = true;
		ZWriteEnable = true;
		CullMode = None;
		VertexShader = compile vs_1_1 DiffuseLBumpVS(mvpMatrix,WorldIMatrix,worldMatrix,lightDir);
        	PixelShader = compile ps_2_0 DiffuseBumpPS2(diffuseSampler,localSampler,bumpHeight);
	}
}

technique TangentSpace_1_1
{

	pass p0
	{
		ZEnable = true;
		ZWriteEnable = true;
		CullMode = None;
		VertexShader = compile vs_1_1 DiffuseBumpVS(mvpMatrix,WorldIMatrix,worldMatrix,lightDir);
        	PixelShader = compile ps_1_1 DiffuseBumpPS1(diffuseSampler,tangentSampler,bumpHeight);
	}
}

technique WorldSpace_1_1
{

	pass p0
	{
		ZEnable = true;
		ZWriteEnable = true;
		CullMode = None;
		VertexShader = compile vs_1_1 DiffuseWBumpVS(mvpMatrix,WorldIMatrix,worldMatrix,lightDir);
        	PixelShader = compile ps_1_1 DiffuseBumpPS1(diffuseSampler,worldSampler,bumpHeight);
	}
}

technique LocalSpace_1_1
{

	pass p0
	{
		ZEnable = true;
		ZWriteEnable = true;
		CullMode = None;
		VertexShader = compile vs_1_1 DiffuseLBumpVS(mvpMatrix,WorldIMatrix,worldMatrix,lightDir);
        	PixelShader = compile ps_1_1 DiffuseBumpPS1(diffuseSampler,localSampler,bumpHeight);
	}
}