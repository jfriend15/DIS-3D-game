﻿Shader "Ripples/ObjectRippleShader"
{
   // defining the main properties as exposed in the inspector
    Properties
    {
        _WidthOfVibration ("vertical width of the vibration", float) = 0.5
        _PeriodOfVibration ("period coeffecient of sine curve of vibration (period is 2pi/this value)", float) = 25.0
        _AmplitudeOfVibration ("amplitude of sine curve of vibration", float) = 3.0
        _BaseColor ("base color of ripple effect", Color) = (0,1,0,1)
        _ColorOffset ("offset of color of middle of ripple effect", float) = 0.5
        
    }
    // start first subshader (there is only one, but there could be multible)
    SubShader
    {
        Tags { "RenderType"="Opaque" } 
        
        Pass 
        {
            CGPROGRAM

            #pragma vertex vertexShader
            #pragma fragment fragmentShader
            
            #include "UnityCG.cginc"
            
            struct vertexInput
            {
                float4 position : POSITION; 
            };
            
            struct vertexOutput
            {
                float4 position : SV_POSITION;
                float4 localPosition : POSITION1;
            };
            
            float _VibrationProgress;
            float _MaxMeshY;
            float _WidthOfVibration;
            float _PeriodOfVibration;
            float _AmplitudeOfVibration;
			
            float4 _BaseColor;         
			float _ColorOffset;

            vertexOutput vertexShader (vertexInput vInput)
            {
                vertexOutput vOutput;
                
                vOutput.localPosition = vInput.position;
                vOutput.position = vInput.position;
                
                if (_VibrationProgress > -1.0) {
                    float relativeHeight = (vOutput.position.y + _MaxMeshY) / (_MaxMeshY * 2);
                    float distanceFromHeight = abs(relativeHeight - _VibrationProgress);
                    if (distanceFromHeight < _WidthOfVibration) {
                        float effectiveHeight = _WidthOfVibration - distanceFromHeight;
                        if (vOutput.position.x < 0) {
                            vOutput.position.x = vOutput.position.x - _AmplitudeOfVibration * sin(_PeriodOfVibration * effectiveHeight);
                        } else {
                            vOutput.position.x = vOutput.position.x + _AmplitudeOfVibration * sin(_PeriodOfVibration * effectiveHeight);
                        }
                        
                        if (vOutput.position.z < 0) {
                            vOutput.position.z = vOutput.position.z - _AmplitudeOfVibration * sin(_PeriodOfVibration * effectiveHeight);
                        } else {
                            vOutput.position.z = vOutput.position.z + _AmplitudeOfVibration * sin(_PeriodOfVibration * effectiveHeight);
                        }
                    } 
                }
                
                // local space into world space transformation:
                vOutput.position = mul(unity_ObjectToWorld, vOutput.position);
                
                // world space into view space transformation:
                vOutput.position = mul(UNITY_MATRIX_V, vOutput.position);
                // view space into clip space transformation:
                vOutput.position = mul(UNITY_MATRIX_P, vOutput.position);

                return vOutput;
            }
            
            fixed4 fragmentShader (vertexOutput vOutput) : SV_Target
            {
                fixed4 col = fixed4(0,0,0,1); //black (default)
                //col = fixed4(0,1,0,1); // DEBUG: uncomment to make objects visible
                
                if (_VibrationProgress > -1.0) {
                    float relativeHeight = (vOutput.localPosition.y + _MaxMeshY) / (_MaxMeshY * 2);
                    float offsetFromRippleCenter = (_WidthOfVibration - abs(relativeHeight - _VibrationProgress)) / _WidthOfVibration - _ColorOffset; 
                    if (abs(relativeHeight - _VibrationProgress) < _WidthOfVibration) {
                        col.r = (_BaseColor.r + offsetFromRippleCenter);
                        col.g = (_BaseColor.g + offsetFromRippleCenter);
						col.b = (_BaseColor.b + offsetFromRippleCenter);
                    } 
                }
                
                return col;
            }

            ENDCG
        }
    }
}
