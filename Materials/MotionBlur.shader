Shader "Hidden/MotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 0
        _EdgeCoeff ("Edge Coefficient", Float) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            half _BlurSize;
            half _EdgeCoeff;

            static const int BLUR_SAMPLE_COUNT = 8;
            // 近い点から遠い点に向かってサンプリングする際の重みづけ係数を設定していく
            // 総和が1になるようにする
            static const float BLUR_WEIGHTS[BLUR_SAMPLE_COUNT] = {
                1.0 / BLUR_SAMPLE_COUNT,
                1.0 / BLUR_SAMPLE_COUNT,
                1.0 / BLUR_SAMPLE_COUNT,
                1.0 / BLUR_SAMPLE_COUNT,
                1.0 / BLUR_SAMPLE_COUNT,
                1.0 / BLUR_SAMPLE_COUNT,
                1.0 / BLUR_SAMPLE_COUNT,
                1.0 / BLUR_SAMPLE_COUNT
            };

            fixed4 frag (v2f i) : SV_Target
            {
                float2 scale = _BlurSize / 1000;
                fixed4 col = 0;
                
                // 画面中心から該当ピクセルまでの方向ベクトル。このベクトルに沿ってぼかしのサンプリングを行う
                float2 dir = float2(i.uv.x - 0.5, i.uv.y - 0.5);

                // 画面中心からの距離。距離が遠いほど強くブラーがかかるようにする。
                float distance = sqrt(dir.x * dir.x + dir.y * dir.y);

                // 方向ベクトルを正規化
                dir /= sqrt(dir.x * dir.x + dir.y * dir.y);

                // 画面の中心から最も遠い点までの距離が1になるように距離を正規化
                distance /= 1.414; // sqrt(2)。画面角までの距離

                distance = pow(distance, _EdgeCoeff); // distanceは0~1の範囲を取るので、2乗することで、より端の方だけを効果の対象にする事が出来る。

                for(int j = 0; j < BLUR_SAMPLE_COUNT; j++){
                    col += tex2D(_MainTex, i.uv + (dir / BLUR_SAMPLE_COUNT) * j * scale * distance) * BLUR_WEIGHTS[j];
                }

                return col;
            }
            ENDCG
        }
    }
}
