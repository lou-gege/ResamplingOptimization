Shader "Custom/GPUGatherShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        ZWrite Off
        Blend off

        Pass
        {
            ZTest off
            Cull off

            CGPROGRAM

            #pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    Texture2D _MainTex;
    SamplerState my_point_clamp_sampler;

    struct VertexInput
    {
        float4 vertex : POSITION;
        half2 texcoord : TEXCOORD0;
    };

    struct VertexOutput
    {
        float4 pos : SV_POSITION;
        half2 uv : TEXCOORD0;
    };

    VertexOutput vert (VertexInput v)
    {
        VertexOutput o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord;

        return o;
    }

    float frag (VertexOutput i) : SV_Target
    {
        float4 col = _MainTex.Gather(my_point_clamp_sampler, i.uv);
        return dot(col, float4(1, 1, 1, 1));
    }

    ENDCG

    FallBack off
}
