Shader "Custom/UVShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    Texture2D _MainTex;
    uniform float4 _MainTex_TexelSize;
    SamplerState my_linear_clamp_sampler, my_point_clamp_sampler;

    struct VertexInput
    {
        float4 vertex : POSITION;
        float2 texcoord : TEXCOORD0;
    };

    struct VertexOutput
    {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
    };

    VertexOutput vert (VertexInput v)
    {
        VertexOutput o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord;

        return o;
    }

    float2 frag (VertexOutput i) : SV_Target
    {
        // return (floor(i.uv / _MainTex_TexelSize.xy) + 0.5) * _MainTex_TexelSize.xy;
        return (floor(i.uv / _MainTex_TexelSize.xy) + float2(0.5f, 0.5f)) * _MainTex_TexelSize.xy;
        // return (floor(i.uv / float2(1.0f/4, 1.0f/4)) + float2(0.5f, 0.5f)) * float2(1.0f/4, 1.0f/4);
        // return _MainTex_TexelSize.xy;
    }

    ENDCG

    FallBack off
}
