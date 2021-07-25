//
// RTOutput_gradient.fx
//

//------------------------------------------------------------------------------------------
//-- Settings
//------------------------------------------------------------------------------------------
float2 fViewportSize = float2(640, 480);
float2 fViewportScale = float2(1, 1);
float2 fViewportPos = float2(0, 0);

float3 fSkyTop = float3(1,0,0);
float3 fSkyBot = float3(0,1,0);

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
// Creates projection matrix of a shadered dxDrawImage
//------------------------------------------------------------------------------------------
float4x4 createImageProjectionMatrix(float2 viewportPos, float2 viewportSize, float2 viewportScale, float adjustZFactor, float nearPlane, float farPlane)
{
    float Q = farPlane / ( farPlane - nearPlane );
    float rcpSizeX = 2.0f / viewportSize.x;
    float rcpSizeY = -2.0f / viewportSize.y;
    rcpSizeX *= adjustZFactor;
    rcpSizeY *= adjustZFactor;
    float viewportPosX = 2 * viewportPos.x;
    float viewportPosY = 2 * viewportPos.y;

    float4x4 sProjection = {
        float4(rcpSizeX * viewportScale.x, 0, 0,  0), float4(0, rcpSizeY * viewportScale.y, 0, 0), float4(viewportPosX, -viewportPosY, Q, 1),
        float4(( -viewportSize.x / 2.0f - 0.5f ) * rcpSizeX,( -viewportSize.y / 2.0f - 0.5f ) * rcpSizeY, -Q * nearPlane , 0)
    };

    return sProjection;
}

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunctionGradiend(VSInput VS)
{
    PSInput PS = (PSInput)0;

    VS.Position.xyz = float3(VS.TexCoord.xy, 0);

    // resize
    VS.Position.xy *= fViewportSize;

    // create projection matrix (as done for shadered dxDrawImage)
    float4x4 sProjection = createImageProjectionMatrix(fViewportPos, fViewportSize, fViewportScale, 101, 100, 10000);

    // calculate screen position of the vertex
    float4 viewPos = mul(float4(VS.Position.xyz, 1), makeTranslation(float3(0,0, 101)));
    PS.Position = mul(viewPos, sProjection);

    // pass texCoords and vertex color to PS
    PS.TexCoord = VS.TexCoord;

    // Calculate GTA lighting for buildings
    PS.Diffuse = VS.Diffuse;

    return PS;
}

//------------------------------------------------------------------------------------------
// Calculate pixel position
//------------------------------------------------------------------------------------------
float3 GetFarClipPosition(float2 coords, float farClip)
{
    // calculations for perspective-correct position recontruction
    float2 uvToViewADD = - 1 / float2(gProjection[0][0], gProjection[1][1]);
    float2 uvToViewMUL = -2.0 * uvToViewADD.xy;
    float4 uvToView = float4(uvToViewMUL, uvToViewADD);
    return float3(coords.x * uvToView.x + uvToView.z, (1 - coords.y) * uvToView.y + uvToView.w, 1.0) * farClip;
}

//------------------------------------------------------------------------------------------
// generates noise
//------------------------------------------------------------------------------------------
float rand21(float2 uv)
{
    float2 noise = frac(sin(dot(uv, float2(12.9898, 78.233) * 2.0)) * 43758.5453);
    return (noise.x + noise.y) * 0.5;
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
Pixel PixelShaderFunctionGradiend(PSInput PS)
{
    Pixel output;

    float3 viewPos = GetFarClipPosition(PS.TexCoord, 820);
    float3 worldPos = mul(float4(viewPos, 1), gViewInverse).xyz;

    float gradient = saturate((worldPos.z - gViewInverse[3].z) * 0.00263);

    // apply sky gradient
    float4 finalColor = float4(lerp(fSkyBot, fSkyTop, gradient), 1);

    // dithering
    float vMov = atan2(gViewInverse[2].x, gViewInverse[2].y);
    float2 jUV = frac(PS.TexCoord + float2(vMov, gViewInverse[2].z));
    gradient = saturate((worldPos.z - gViewInverse[3].z) * 0.0015);
    gradient = ((worldPos.z - gViewInverse[3].z) < 0) ? 1 : gradient;
    finalColor.xyz += (( - rand21(jUV) * 0.008) + 0.004 ) * saturate(1 - gradient);
    finalColor.xyz = max(finalColor.xyz, 0.0);

    // Output
    output.World = saturate(finalColor);
    output.Depth = 0.99999f;

    return output;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique RTOutput_gradient
{
  pass P0
  {
    ZEnable = true;
    ZFunc = LessEqual;
    ZWriteEnable = false;
    CullMode = 1;
    ShadeMode = Gouraud;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = InvSrcAlpha;
    AlphaTestEnable = true;
    AlphaRef = 1;
    AlphaFunc = GreaterEqual;
    Lighting = false;
    FogEnable = false;
    SRGBWriteEnable = false;
    VertexShader = compile vs_3_0 VertexShaderFunctionGradiend();
    PixelShader = compile ps_3_0 PixelShaderFunctionGradiend();
  }
}

technique RTOutput_gradient_PS2
{
  pass P0
  {
    ZEnable = true;
    ZFunc = LessEqual;
    ZWriteEnable = false;
    CullMode = 1;
    ShadeMode = Gouraud;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = One;
    AlphaTestEnable = true;
    AlphaRef = 1;
    AlphaFunc = GreaterEqual;
    Lighting = false;
    FogEnable = false;
    SRGBWriteEnable = false;
    VertexShader = compile vs_2_0 VertexShaderFunctionGradiend();
    PixelShader = compile ps_2_0 PixelShaderFunctionGradiend();
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
