Shader "Hidden/MotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 0
        _EdgeCoeff ("Edge Coefficient", Float) = 1
        _SpeedCoeff ("Speed Coefficient", Float) = 0
        _BlurCenterPoint ("Blur Center Point", Vector) = (0.5, 0.5, 0.0)
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
            half _EdgeCoeff; // 端の方だけに効果をかけるために使用する係数。大きいほど端のみに効果が表れる
            half _SpeedCoeff; // スピードに応じて増減させる係数(0~1)。大きくするほど効果が強くなる。ゲーム側の最高速度で1に、停止中は0にする。
            half2 _BlurCenterPoint; // ブラーの中心となる点

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

            float magnitude(float2 vec){
                return max(abs(vec.x), abs(vec.y));
            }

            // 画面上におけるブラーの中心点までの最大距離を計算する
            float calcMaxDistance()
            {
                // どの点が中心点だったとしても、最大距離を取るのは四角のどれか
                float distance1 = magnitude(float2(0, 0) - _BlurCenterPoint);
                float distance2 = magnitude(float2(1, 0) - _BlurCenterPoint);
                float distance3 = magnitude(float2(0, 1) - _BlurCenterPoint);
                float distance4 = magnitude(float2(1, 1) - _BlurCenterPoint);

                float maxDistance = max(distance1, max(distance2, max(distance3, distance4)));

                return maxDistance;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = 0;
                
                // ブラーの中心から該当ピクセルまでの方向ベクトル。このベクトルに沿ってサンプリングを行う
                float2 dir = i.uv - _BlurCenterPoint;

                // ブラーの中心からの距離。距離が遠いほど強くブラーがかかるようにする。
                // ここでアスペクト比を考慮すれば画面上下端に左右端と同じだけの効果を与えることが出来るかもしれない(今回は純粋に距離だけを見たいのでそうしない)
                float distance = magnitude(dir);

                // 方向ベクトルを正規化
                dir /= sqrt(dir.x * dir.x + dir.y * dir.y);

                // 画面の中心から最も遠い点までの距離が1になるように距離を正規化
                distance /= calcMaxDistance(); 

                distance = pow(distance, _EdgeCoeff); // distanceは0~1の範囲を取るので、累乗することで、より端の方だけを効果の対象にする事が出来る。

                for(int j = 0; j < BLUR_SAMPLE_COUNT; j++){
                    float2 samplePoint = i.uv - dir / BLUR_SAMPLE_COUNT * j * distance * _SpeedCoeff *_BlurSize;
                    col += tex2D(_MainTex, samplePoint) * BLUR_WEIGHTS[j] ;
                }

                return col;
            }
            ENDCG
        }
    }
}
