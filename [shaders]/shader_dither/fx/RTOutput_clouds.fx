//
// RTOutput_clouds.fx
//

//------------------------------------------------------------------------------------------
//-- Settings
//------------------------------------------------------------------------------------------
float2 fViewportSize = float2(800, 600);
float2 fViewportScale = float2(1, 1);
float2 fViewportPos = float2(0, 0);

bool bResAspectBug = true;
float2 sCloudSize = float2(4.3,0.4);
float4 sCloudColor = float4(0,0,0,0);
float sBaseHeight = 60;

float3 cloudVec[12]=
    {
        float3(-0.017854493111372, -0.99983841180801, -0.0021016525570303),
        float3(-0.73024141788483, -0.68217295408249, -0.037249282002449),
        float3(-0.47874602675438, -0.87010115385056, 0.11715991050005),
        float3(0.4492035806179, -0.89026147127151, 0.075171142816544),
        float3(0.6849524974823, -0.72706383466721, 0.047099679708481),
        float3(0.99932944774628, -0.020671565085649, -0.030222041532397),
        float3(0.90503495931625, 0.41431847214699, 0.096186928451061),
        float3(0.73456698656082, 0.6784747838974, -0.0091327410191298),
        float3(0.016465790569782, 0.99906098842621, 0.040075149387121),
        float3(-0.70189046859741, 0.71228188276291, -0.002101615536958),
        float3(-0.87473541498184, 0.47495901584625, 0.096186943352222),
        float3(-0.99778300523758, 0.026287212967873, 0.061141490936279)
    };	

//--------------------------------------------------------------------------------------
// Textures
//--------------------------------------------------------------------------------------
texture sTexCloud;

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
sampler2D SamplerCloud = sampler_state
{
    Texture = (sTexCloud);
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
PSInput VertexShaderFunctionCloud(VSInput VS, uniform float index)
{
    PSInput PS = (PSInput)0;
	
    // set proper position and scale of the quad
    VS.Position.xyz = float3(- 0.5 + VS.TexCoord.xy, 0);
	
    VS.Position.xy *= sCloudSize * 250;
	
    // recreate resolution aspect bug for moon and stars
    if (bResAspectBug) VS.Position.y /= (fViewportSize.x / fViewportSize.y) * 0.75;
	
    // create WorldMatrix for the quad
    float3 sCameraPosition = gViewInverse[3].xyz;
    sCameraPosition.z = sBaseHeight;
    float3 elementPosition = sCameraPosition + 250 * PI * normalize(cloudVec[index]);
    float4x4 sWorld = makeTranslation(elementPosition);

    // calculate screen position of the vertex
    float4x4 sWorldView = mul(sWorld, gView);
    float3 sBillView = VS.Position.xyz + sWorldView[3].xyz;
    PS.Position = mul(float4(sBillView, 1), gProjection);
    PS.Position.z *= 0.01;

    // pass texCoords and vertex color to PS
    VS.TexCoord.y = 1 - VS.TexCoord.y;
    PS.TexCoord = VS.TexCoord;
	
    PS.Diffuse = sCloudColor;
	
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
Pixel PixelShaderFunctionCloud(PSInput PS)
{
    Pixel output;
	
    // sample color texture
    float4 finalColor = tex2D(SamplerCloud, PS.TexCoord.xy);
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
    VertexShader = compile vs_2_0 VertexShaderFunctionCloud(0);
    PixelShader  = compile ps_2_0 PixelShaderFunctionCloud();
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
    VertexShader = compile vs_2_0 VertexShaderFunctionCloud(1);
    PixelShader  = compile ps_2_0 PixelShaderFunctionCloud();
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
    VertexShader = compile vs_2_0 VertexShaderFunctionCloud(2);
    PixelShader  = compile ps_2_0 PixelShaderFunctionCloud();
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
    VertexShader = compile vs_2_0 VertexShaderFunctionCloud(3);
    PixelShader  = compile ps_2_0 PixelShaderFunctionCloud();
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
    VertexShader = compile vs_2_0 VertexShaderFunctionCloud(4);
    PixelShader  = compile ps_2_0 PixelShaderFunctionCloud();
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
    VertexShader = compile vs_2_0 VertexShaderFunctionCloud(5);
    PixelShader  = compile ps_2_0 PixelShaderFunctionCloud();
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
    VertexShader = compile vs_2_0 VertexShaderFunctionCloud(6);
    PixelShader  = compile ps_2_0 PixelShaderFunctionCloud();
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
    VertexShader = compile vs_2_0 VertexShaderFunctionCloud(7);
    PixelShader  = compile ps_2_0 PixelShaderFunctionCloud();
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
    VertexShader = compile vs_2_0 VertexShaderFunctionCloud(8);
    PixelShader  = compile ps_2_0 PixelShaderFunctionCloud();
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
    VertexShader = compile vs_2_0 VertexShaderFunctionCloud(9);
    PixelShader  = compile ps_2_0 PixelShaderFunctionCloud();
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
    VertexShader = compile vs_2_0 VertexShaderFunctionCloud(10);
    PixelShader  = compile ps_2_0 PixelShaderFunctionCloud();
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
    VertexShader = compile vs_2_0 VertexShaderFunctionCloud(11);
    PixelShader  = compile ps_2_0 PixelShaderFunctionCloud();
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
