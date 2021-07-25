//
// RTOutput_moonStars.fx
//

//------------------------------------------------------------------------------------------
//-- Settings
//------------------------------------------------------------------------------------------
float2 fViewportSize = float2(800, 600);
float2 fViewportScale = float2(1, 1);
float2 fViewportPos = float2(0, 0);

bool bResAspectBug = true;
float3 sMoonVec = float3(0.0004, -0.9895, 0.15);
float sMoonSize = 3;

float3 sMoonColor = float3(1,1,1);
float3 sStarColor = float3(1,1,1);

float3 starVec[12]=
    {
        float3(-0.995, 0.000, 0.0997),
        float3(-0.9086, -0.0395, 0.418),
        float3(0.74106830, -0.6673825, 0.073609),
        float3(0.995, 0.000206, 0.099749892950058),
        float3(0.9078, -0.040437, 0.41742),
        float3(0.8008, -0.4329, 0.413781),
        float3(0.8792, -0.21406, 0.42565),
        float3(0.848298, -0.42017, 0.32225),
        float3(0.81051, -0.5466, 0.210463),
        float3(0.76991, -0.090464, 0.6317),
        float3(0.7182, -0.259, 0.6458),
        float3(0.70614, -0.4447, 0.55096)
    };
float2 starSize[12]=
    {
        float2(0.0873, 0.065),
        float2(0.0873, 0.065),
        float2(0.31, 0.23),
        float2(0.0776, 0.052),
        float2(0.0873, 0.0845),
        float2(0.0873, 0.065),
        float2(0.0873, 0.065),
        float2(0.06305, 0.052),	
        float2(0.04365, 0.0468),
        float2(0.03686, 0.0338),
        float2(0.03686, 0.0338),
        float2(0.0291, 0.026)
    };	

//--------------------------------------------------------------------------------------
// Textures
//--------------------------------------------------------------------------------------
texture sTexMoon;
texture sTexStar;

//------------------------------------------------------------------------------------------
// Include some common stuff
//------------------------------------------------------------------------------------------
static const float PI = 3.14159265f;
float4x4 gProjection : PROJECTION;
float4x4 gView : VIEW;
float4x4 gViewInverse : VIEWINVERSE;
float gTime : TIME;
int CUSTOMFLAGS < string skipUnusedParameters = "yes"; >;

//------------------------------------------------------------------------------------------
//-- Sampler for the main texture (needed for pixel shaders)
//------------------------------------------------------------------------------------------
sampler2D SamplerMoon = sampler_state
{
    Texture = (sTexMoon);
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    AddressU = Border;
    AddressV = Border;
    BorderColor = float4(0,0,0,0);
    MaxMipLevel = 0;
    MipMapLodBias = 0;
};

sampler2D SamplerStar = sampler_state
{
    Texture = (sTexStar);
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    AddressU = Border;
    AddressV = Border;
    BorderColor = float4(0,0,0,0);
    MaxMipLevel = 0;
    MipMapLodBias = 0;
};


//------------------------------------------------------------------------------------------
// Structure of data sent to the vertex shader
//------------------------------------------------------------------------------------------
struct VSInput
{
    float3 Position : POSITION0;
    float3 Normal : NORMAL0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

//------------------------------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//------------------------------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

//------------------------------------------------------------------------------------------
// Returns a translation matrix
//------------------------------------------------------------------------------------------
float4x4 makeTranslation( float3 trans) 
{
  return float4x4(
     1,  0,  0,  0,
     0,  1,  0,  0,
     0,  0,  1,  0,
     trans.x, trans.y, trans.z, 1
  );
}

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunctionMoon(VSInput VS)
{
    PSInput PS = (PSInput)0;
	
    // set proper position and scale of the quad
    VS.Position.xyz = float3(- 0.5 + VS.TexCoord.xy, 0);
	
    VS.Position.xy *=  0.4 + saturate((sMoonSize * 0.6) / 3);
    VS.Position.xy *= float2(0.95, 0.72);
	
    // recreate resolution aspect bug for moon and stars
    if (bResAspectBug) VS.Position.y /= (fViewportSize.x / fViewportSize.y) * 0.75;
	
    // create WorldMatrix for the quad
    float3 elementPosition = gViewInverse[3].xyz + PI * normalize(sMoonVec);
    float4x4 sWorld = makeTranslation(elementPosition);

    // calculate screen position of the vertex
    float4x4 sWorldView = mul(sWorld, gView);
    float3 sBillView = VS.Position.xyz + sWorldView[3].xyz;
    PS.Position = mul(float4(sBillView, 1), gProjection);

    // pass texCoords and vertex color to PS
    VS.TexCoord.y = 1 - VS.TexCoord.y;
    PS.TexCoord = VS.TexCoord;
    PS.Diffuse = float4(sMoonColor, 1);
	
    return PS;
}


PSInput VertexShaderFunctionStar(VSInput VS, uniform float index)
{
    PSInput PS = (PSInput)0;
	
    // set proper position and scale of the quad
    VS.Position.xyz = float3(- 0.5 + VS.TexCoord.xy, 0);
	
    VS.Position.xy *= starSize[index] * 1.15;
	
    // recreate resolution aspect bug for moon and stars
    if (bResAspectBug) VS.Position.y /= (fViewportSize.x / fViewportSize.y) * 0.75;
	
    // create WorldMatrix for the quad
    float3 elementPosition = gViewInverse[3].xyz + PI * normalize(starVec[index]);
    float4x4 sWorld = makeTranslation(elementPosition);

    // calculate screen position of the vertex
    float4x4 sWorldView = mul(sWorld, gView);
    float3 sBillView = VS.Position.xyz + sWorldView[3].xyz;
    PS.Position = mul(float4(sBillView, 1), gProjection);

    // pass texCoords and vertex color to PS
    VS.TexCoord.y = 1 - VS.TexCoord.y;
    PS.TexCoord = VS.TexCoord;
	
    float starBlink = 0.75 + 0.25 * sin(fmod(gTime * 25, 1) * PI);
	
    PS.Diffuse = float4(sStarColor, starBlink);
	
    return PS;
}

//------------------------------------------------------------------------------------------
// Structure of color data sent to the renderer ( from the pixel shader  )
//------------------------------------------------------------------------------------------
struct Pixel
{
    float4 World : COLOR0;      // Render target #0
    float Depth : DEPTH;        // Depth target
};

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
Pixel PixelShaderFunctionMoon(PSInput PS)
{
    Pixel output;
	
    // sample color texture
    float4 finalColor = tex2D(SamplerMoon, PS.TexCoord.xy);
    finalColor *= PS.Diffuse;
	
    // output
    output.World = saturate(finalColor);
    output.Depth = 0.99999f;
 
    return output;
}

Pixel PixelShaderFunctionStar(PSInput PS)
{
    Pixel output;
	
    // sample color texture
    float4 finalColor = tex2D(SamplerStar, PS.TexCoord.xy);
    finalColor *= PS.Diffuse;
	
    // output
    output.World = saturate(finalColor);
    output.Depth = 0.99999f;
 
    return output;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique RTOutput_moonStars
{
  pass P0
  {
    ZEnable = true;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionMoon();
    PixelShader  = compile ps_2_0 PixelShaderFunctionMoon();
  }
  pass P1
  {
    ZEnable = true;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionStar(0);
    PixelShader  = compile ps_2_0 PixelShaderFunctionStar();
  }
  pass P2
  {
    ZEnable = true;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionStar(1);
    PixelShader  = compile ps_2_0 PixelShaderFunctionStar();
  }  
  pass P3
  {
    ZEnable = true;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionStar(2);
    PixelShader  = compile ps_2_0 PixelShaderFunctionStar();
  } 
  pass P4
  {
    ZEnable = true;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionStar(3);
    PixelShader  = compile ps_2_0 PixelShaderFunctionStar();
  } 
  pass P5
  {
    ZEnable = true;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionStar(4);
    PixelShader  = compile ps_2_0 PixelShaderFunctionStar();
  } 
  pass P6
  {
    ZEnable = true;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionStar(5);
    PixelShader  = compile ps_2_0 PixelShaderFunctionStar();
  } 
  pass P7
  {
    ZEnable = true;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionStar(6);
    PixelShader  = compile ps_2_0 PixelShaderFunctionStar();
  } 
  pass P8
  {
    ZEnable = true;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionStar(7);
    PixelShader  = compile ps_2_0 PixelShaderFunctionStar();
  } 
  pass P9
  {
    ZEnable = true;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionStar(8);
    PixelShader  = compile ps_2_0 PixelShaderFunctionStar();
  } 
  pass P10
  {
    ZEnable = true;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionStar(9);
    PixelShader  = compile ps_2_0 PixelShaderFunctionStar();
  } 
  pass P11
  {
    ZEnable = true;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionStar(10);
    PixelShader  = compile ps_2_0 PixelShaderFunctionStar();
  } 
  pass P12
  {
    ZEnable = true;
    ZWriteEnable = false;
    CullMode = 1;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    FogEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionStar(11);
    PixelShader  = compile ps_2_0 PixelShaderFunctionStar();
  }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
