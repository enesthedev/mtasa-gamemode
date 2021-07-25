#include "helper.fx"

  float4 color = 1;

  sampler Sampler0 : register( s0 );

  struct VSInput
  {
      float4 Position     : POSITION0;
      float3 Normal   : NORMAL0;
      float4 Diffuse  : COLOR0;
      float2 TexCoord     : TEXCOORD0;
  };

  struct PSInput
  {
      float4 Position     : POSITION0;
      float2 TexCoord     : TEXCOORD0;
      float4 Diffuse  : COLOR0;
  };

  PSInput VertexShaderFunction( VSInput VS )
  {
      PSInput PS = (PSInput)0;

      float4 worldPosition    = mul( VS.Position, gWorld );
      float4 viewPosition     = mul( worldPosition, gView );
      float4 position         = mul( viewPosition, gProjection );

      PS.Position     = position;
      PS.TexCoord     = VS.TexCoord;

      PS.Diffuse      = MTACalcGTABuildingDiffuse( VS.Diffuse );

      return PS;
  }

  float4 PixelShaderFunction( PSInput PS ) : COLOR0
  {
      float4 texColor = tex2D( Sampler0, PS.TexCoord );

      texColor *= color;

      return texColor;
  }

  technique
  {
      pass P0
      {
          VertexShader    = compile vs_2_0 VertexShaderFunction();
          PixelShader     = compile ps_2_0 PixelShaderFunction();
      }
  }