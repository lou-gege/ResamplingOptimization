Shader "Custom/GradientShader_2x"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _UpSamplingTex ("Texture", 2D) = "white" {}
        _TruthTex ("Texture", 2D) = "white" {}
        _GradientPart ("GradientPart", Float) = 0.0
        // _Step ("Step", Float) = 1.0
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

            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex, _TruthTex, _UpSamplingTex;
    uniform half4 _UpSamplingTex_TexelSize;
    float _GradientPart;

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

    float4 frag (VertexOutput i) : SV_Target
    {
        float4 currCol = tex2D(_MainTex, i.uv);
        
        half3 upSampleIndex[16];
        half xIndex, yIndex, xWeight, yWeight, weight;
        // 11
        xIndex = i.uv.x - _UpSamplingTex_TexelSize * 1.5;
        yIndex = i.uv.y - _UpSamplingTex_TexelSize * 1.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        upSampleIndex[0] = half3(xIndex, yIndex, xWeight * yWeight);
        // 12
        xIndex = i.uv.x - _UpSamplingTex_TexelSize * 0.5;
        yIndex = i.uv.y - _UpSamplingTex_TexelSize * 1.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        upSampleIndex[1] = half3(xIndex, yIndex, xWeight * yWeight);
        // 13
        xIndex = i.uv.x + _UpSamplingTex_TexelSize * 0.5;
        yIndex = i.uv.y - _UpSamplingTex_TexelSize * 1.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        upSampleIndex[2] = half3(xIndex, yIndex, xWeight * yWeight);
        // 14
        xIndex = i.uv.x + _UpSamplingTex_TexelSize * 1.5;
        yIndex = i.uv.y - _UpSamplingTex_TexelSize * 1.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        upSampleIndex[3] = half3(xIndex, yIndex, xWeight * yWeight);
        // 21
        xIndex = i.uv.x - _UpSamplingTex_TexelSize * 1.5;
        yIndex = i.uv.y - _UpSamplingTex_TexelSize * 0.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        upSampleIndex[4] = half3(xIndex, yIndex, xWeight * yWeight);
        // 22
        xIndex = i.uv.x - _UpSamplingTex_TexelSize * 0.5;
        yIndex = i.uv.y - _UpSamplingTex_TexelSize * 0.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        upSampleIndex[5] = half3(xIndex, yIndex, xWeight * yWeight);
        // 23
        xIndex = i.uv.x + _UpSamplingTex_TexelSize * 0.5;
        yIndex = i.uv.y - _UpSamplingTex_TexelSize * 0.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        upSampleIndex[6] = half3(xIndex, yIndex, xWeight * yWeight);
        // 24
        xIndex = i.uv.x + _UpSamplingTex_TexelSize * 1.5;
        yIndex = i.uv.y - _UpSamplingTex_TexelSize * 0.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        upSampleIndex[7] = half3(xIndex, yIndex, xWeight * yWeight);
        // 31
        xIndex = i.uv.x - _UpSamplingTex_TexelSize * 1.5;
        yIndex = i.uv.y + _UpSamplingTex_TexelSize * 0.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        upSampleIndex[8] = half3(xIndex, yIndex, xWeight * yWeight);
        // 32
        xIndex = i.uv.x - _UpSamplingTex_TexelSize * 0.5;
        yIndex = i.uv.y + _UpSamplingTex_TexelSize * 0.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        upSampleIndex[9] = half3(xIndex, yIndex, xWeight * yWeight);
        // 33
        xIndex = i.uv.x + _UpSamplingTex_TexelSize * 0.5;
        yIndex = i.uv.y + _UpSamplingTex_TexelSize * 0.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        upSampleIndex[10] = half3(xIndex, yIndex, xWeight * yWeight);
        // 34
        xIndex = i.uv.x + _UpSamplingTex_TexelSize * 1.5;
        yIndex = i.uv.y + _UpSamplingTex_TexelSize * 0.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        upSampleIndex[11] = half3(xIndex, yIndex, xWeight * yWeight);
        // 41
        xIndex = i.uv.x - _UpSamplingTex_TexelSize * 1.5;
        yIndex = i.uv.y + _UpSamplingTex_TexelSize * 1.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        upSampleIndex[12] = half3(xIndex, yIndex, xWeight * yWeight);
        // 42
        xIndex = i.uv.x - _UpSamplingTex_TexelSize * 0.5;
        yIndex = i.uv.y + _UpSamplingTex_TexelSize * 1.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        upSampleIndex[13] = half3(xIndex, yIndex, xWeight * yWeight);
        // 43
        xIndex = i.uv.x + _UpSamplingTex_TexelSize * 0.5;
        yIndex = i.uv.y + _UpSamplingTex_TexelSize * 1.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.75;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        upSampleIndex[14] = half3(xIndex, yIndex, xWeight * yWeight);
        // 44
        xIndex = i.uv.x + _UpSamplingTex_TexelSize * 1.5;
        yIndex = i.uv.y + _UpSamplingTex_TexelSize * 1.5;
        xWeight = (xIndex < _UpSamplingTex_TexelSize || xIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        yWeight = (yIndex < _UpSamplingTex_TexelSize || yIndex + _UpSamplingTex_TexelSize > 1) ? 1 : 0.25;
        upSampleIndex[15] = half3(xIndex, yIndex, xWeight * yWeight);

        float3 gradient = float3(0.0, 0.0, 0.0);
        for(int i = 0; i < 16; i++){
            if(upSampleIndex[i].x > 0 && upSampleIndex[i].x < 1 && upSampleIndex[i].y > 0 && upSampleIndex[i].y < 1){
                float4 truthCol = tex2D(_TruthTex, upSampleIndex[i].xy);
                float4 upSampleCol = tex2D(_UpSamplingTex, upSampleIndex[i].xy);
                gradient += (upSampleCol.rgb - truthCol.rgb) * upSampleIndex[i].z;
            }
        }
        
        gradient *= _GradientPart;
        float3 col = currCol.rgb - gradient;

        return float4(col, 1.0);
    }

    ENDCG

    FallBack off
}
