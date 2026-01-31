#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// MARK: - Color Palette (Groot Colors as half4)

constant half4 shieldColor = half4(0.345h, 0.8h, 0.008h, 1.0h);      // #58CC02
constant half4 forestColor = half4(0.345h, 0.655h, 0.0h, 1.0h);      // #58A700
constant half4 leafColor = half4(0.537h, 0.886h, 0.098h, 1.0h);      // #89E219
constant half4 barkColor = half4(0.294h, 0.294h, 0.294h, 1.0h);      // #4B4B4B
constant half4 whiteColor = half4(1.0h, 1.0h, 1.0h, 1.0h);           // #FFFFFF
constant half4 flameColor = half4(1.0h, 0.294h, 0.294h, 1.0h);       // #FF4B4B
constant half4 cheekColor = half4(1.0h, 0.6h, 0.6h, 0.4h);           // Rosy cheeks

// MARK: - SDF Primitives

// Signed distance to a circle
float sdCircle(float2 p, float r) {
    return length(p) - r;
}

// Signed distance to a rounded box
float sdRoundedBox(float2 p, float2 b, float r) {
    float2 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

// Signed distance to an ellipse (approximate)
float sdEllipse(float2 p, float2 ab) {
    float2 pa = abs(p);
    float2 ra = ab;
    
    // Approximate ellipse SDF
    float k0 = length(pa / ra);
    float k1 = length(pa / (ra * ra));
    return k0 * (k0 - 1.0) / k1;
}

// Signed distance to a capsule/stadium shape
float sdCapsule(float2 p, float2 a, float2 b, float r) {
    float2 pa = p - a;
    float2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - r;
}

// Signed distance to a line segment
float sdSegment(float2 p, float2 a, float2 b) {
    float2 pa = p - a;
    float2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

// MARK: - SDF Operations

float opSmoothUnion(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

float opSmoothSubtraction(float d1, float d2, float k) {
    float h = clamp(0.5 - 0.5 * (d2 + d1) / k, 0.0, 1.0);
    return mix(d2, -d1, h) + k * h * (1.0 - h);
}

// MARK: - Helper Functions

// Smooth fill from SDF
half fillSDF(float d, float smoothness) {
    return 1.0h - half(smoothstep(0.0, smoothness, d));
}

// Soft glow from SDF
half glowSDF(float d, float intensity, float radius) {
    return half(intensity / (1.0 + max(d, 0.0) * radius));
}

// MARK: - Shield Body Shape

float sdShieldBody(float2 p, float scale) {
    // Shield is a combination of rounded rectangle and curved bottom
    float2 sp = p / scale;
    
    // Main body - slightly taller rounded rectangle
    float body = sdRoundedBox(sp + float2(0.0, 0.05), float2(0.35, 0.4), 0.15);
    
    // Curved bottom point - using a circle subtraction to create shield point
    float bottomCurve = sdCircle(sp + float2(0.0, 0.55), 0.25);
    
    // Combine: union of body with bottom, creating shield shape
    float shield = opSmoothUnion(body, bottomCurve, 0.1);
    
    // Cut off the very bottom to make it pointier
    float cutPlane = -sp.y - 0.45;
    shield = max(shield, cutPlane);
    
    return shield * scale;
}

// MARK: - Face Features

// Eyes with blink and mood support
float sdEye(float2 p, float2 center, float radius, float blink, float mood) {
    float2 ep = p - center;
    
    // Base eye circle
    float eye = sdCircle(ep, radius);
    
    // Blink: squash the eye vertically
    // When blink > 0, we compress the y coordinate
    float blinkSquash = mix(1.0, 0.1, blink);
    float2 blinkP = float2(ep.x, ep.y / blinkSquash);
    float blinkEye = sdCircle(blinkP, radius);
    
    // Sleeping eyes (mood ~= 3): horizontal line
    float sleepEye = abs(ep.y) - radius * 0.15;
    sleepEye = max(sleepEye, abs(ep.x) - radius);
    
    // Happy eyes (mood ~= 1): curved "^" shape
    float happyEye = abs(ep.y + abs(ep.x) * 0.8) - radius * 0.2;
    happyEye = max(happyEye, abs(ep.x) - radius);
    
    // Mix based on mood: 0=idle, 1=happy, 2=blocking, 3=sleeping
    float idleHappy = mix(blinkEye, happyEye, smoothstep(0.5, 1.5, mood));
    float normalSleep = mix(idleHappy, sleepEye, smoothstep(2.5, 3.5, mood));
    
    return normalSleep;
}

// Pupil that can move
float sdPupil(float2 p, float2 eyeCenter, float2 lookDir, float eyeRadius, float pupilRadius) {
    // Pupil moves within eye based on look direction
    float2 pupilOffset = lookDir * eyeRadius * 0.3;
    float2 pupilCenter = eyeCenter + pupilOffset;
    return sdCircle(p - pupilCenter, pupilRadius);
}

// Mouth shape
float sdMouth(float2 p, float2 center, float mood, float time) {
    float2 mp = p - center;
    
    // Idle/default: small smile curve
    float smileWidth = 0.08;
    float smileHeight = 0.02 + sin(time * 2.0) * 0.005; // Subtle animation
    
    // Happy: bigger smile
    float happyWidth = 0.12;
    float happyHeight = 0.04;
    
    // Blocking: straight line (serious)
    float blockWidth = 0.06;
    
    // Sleeping: small "o" shape
    float sleepRadius = 0.02;
    
    // Interpolate mouth shapes based on mood
    float width = mix(smileWidth, happyWidth, smoothstep(0.5, 1.5, mood));
    width = mix(width, blockWidth, smoothstep(1.5, 2.5, mood));
    
    float height = mix(smileHeight, happyHeight, smoothstep(0.5, 1.5, mood));
    height = mix(height, 0.005, smoothstep(1.5, 2.5, mood));
    
    // Smile as a capsule curve
    float smile = sdCapsule(mp, float2(-width, 0.0), float2(width, 0.0), 0.015);
    
    // Add curve for smile
    float curve = mp.y + (1.0 - pow(mp.x / width, 2.0)) * height;
    smile = max(smile, -curve);
    
    // Sleeping "o" mouth
    float sleepMouth = sdCircle(mp, sleepRadius);
    
    // Mix in sleeping mouth
    float finalMouth = mix(smile, sleepMouth, smoothstep(2.5, 3.5, mood));
    
    return finalMouth;
}

// MARK: - Arms

float sdArm(float2 p, float2 shoulderPos, float armAngle, float length, float thickness) {
    // Arm as a capsule from shoulder
    float2 armEnd = shoulderPos + float2(cos(armAngle), sin(armAngle)) * length;
    return sdCapsule(p, shoulderPos, armEnd, thickness);
}

// MARK: - Main Mascot Shader

[[ stitchable ]]
half4 grootMascot(
    float2 position,
    half4 currentColor,
    float2 size,
    float time,
    float mood,         // 0=idle, 1=happy, 2=blocking, 3=sleeping
    float blink,        // 0-1 blink progress
    float breathe       // Breathing scale factor
) {
    // Normalize coordinates to center, aspect-corrected
    float2 uv = (position - size * 0.5) / min(size.x, size.y);
    
    // Apply breathing scale
    float breatheScale = 1.0 + breathe * 0.02;
    uv /= breatheScale;
    
    // Slight bounce for happy mood
    float happyBounce = smoothstep(0.5, 1.5, mood) * sin(time * 8.0) * 0.01;
    uv.y -= happyBounce;
    
    // Shake for blocking mood
    float blockShake = smoothstep(1.5, 2.5, mood) * sin(time * 30.0) * 0.005;
    uv.x += blockShake;
    
    // Scale factor for the mascot
    float scale = 0.4;
    
    // Initialize output color (transparent)
    half4 color = half4(0.0h);
    
    // MARK: - Outer Glow
    
    float shieldDist = sdShieldBody(uv, scale);
    half glowIntensity = glowSDF(shieldDist, 0.15, 8.0);
    
    // Glow color changes with mood
    half4 glowColor = leafColor;
    glowColor = mix(glowColor, half4(1.0h, 0.9h, 0.3h, 1.0h), half(smoothstep(0.5, 1.5, mood))); // Yellow for happy
    glowColor = mix(glowColor, flameColor, half(smoothstep(1.5, 2.5, mood))); // Red for blocking
    glowColor = mix(glowColor, half4(0.5h, 0.5h, 0.7h, 1.0h), half(smoothstep(2.5, 3.5, mood))); // Dim blue for sleeping
    
    // Pulse glow
    float glowPulse = 1.0 + sin(time * 2.0) * 0.2;
    glowIntensity *= half(glowPulse);
    
    color = mix(color, glowColor, glowIntensity * 0.5h);
    
    // MARK: - Shield Body
    
    half bodyFill = fillSDF(shieldDist, 0.01);
    
    // Body gradient: lighter at top, darker at bottom
    half bodyGradient = half(smoothstep(-0.3, 0.2, uv.y));
    half4 bodyColor = mix(forestColor, shieldColor, bodyGradient);
    
    // Add subtle highlight at top
    half highlight = half(1.0 - smoothstep(-0.25, -0.15, uv.y)) * 0.3h;
    bodyColor = mix(bodyColor, whiteColor, highlight * bodyFill);
    
    color = mix(color, bodyColor, bodyFill);
    
    // MARK: - Shadow/Depth on body
    
    float innerShadow = sdShieldBody(uv + float2(0.0, 0.02), scale * 0.95);
    half shadowFill = fillSDF(innerShadow, 0.02) * bodyFill;
    color = mix(color, forestColor, shadowFill * 0.3h);
    
    // MARK: - Eyes
    
    float2 leftEyePos = float2(-0.08, -0.05);
    float2 rightEyePos = float2(0.08, -0.05);
    float eyeRadius = 0.055;
    float pupilRadius = 0.025;
    
    // Eye whites
    float leftEyeDist = sdEye(uv, leftEyePos, eyeRadius, blink, mood);
    float rightEyeDist = sdEye(uv, rightEyePos, eyeRadius, blink, mood);
    
    half leftEyeFill = fillSDF(leftEyeDist, 0.005);
    half rightEyeFill = fillSDF(rightEyeDist, 0.005);
    
    // Only show white eyes when not in sleeping mode
    half eyeVisibility = 1.0h - half(smoothstep(2.5, 3.0, mood));
    color = mix(color, whiteColor, leftEyeFill * eyeVisibility);
    color = mix(color, whiteColor, rightEyeFill * eyeVisibility);
    
    // Pupils - drift slowly in idle, look direction based on time
    float2 lookDir = float2(sin(time * 0.5) * 0.3, cos(time * 0.7) * 0.2);
    
    // In blocking mode, eyes look forward (serious)
    lookDir = mix(lookDir, float2(0.0), smoothstep(1.5, 2.5, mood));
    
    float leftPupilDist = sdPupil(uv, leftEyePos, lookDir, eyeRadius, pupilRadius);
    float rightPupilDist = sdPupil(uv, rightEyePos, lookDir, eyeRadius, pupilRadius);
    
    half leftPupilFill = fillSDF(leftPupilDist, 0.003) * leftEyeFill;
    half rightPupilFill = fillSDF(rightPupilDist, 0.003) * rightEyeFill;
    
    // Don't show pupils in happy (^_^) or sleeping mode
    half pupilVisibility = 1.0h - half(smoothstep(0.5, 1.0, mood));
    pupilVisibility = max(pupilVisibility, half(smoothstep(1.5, 2.0, mood)) * (1.0h - half(smoothstep(2.5, 3.0, mood))));
    
    color = mix(color, barkColor, leftPupilFill * pupilVisibility);
    color = mix(color, barkColor, rightPupilFill * pupilVisibility);
    
    // Eye shine (small white dot)
    float2 shineOffset = float2(-0.015, -0.015);
    float leftShineDist = sdCircle(uv - leftEyePos - shineOffset, 0.012);
    float rightShineDist = sdCircle(uv - rightEyePos - shineOffset, 0.012);
    
    half leftShineFill = fillSDF(leftShineDist, 0.003) * leftEyeFill * pupilVisibility;
    half rightShineFill = fillSDF(rightShineDist, 0.003) * rightEyeFill * pupilVisibility;
    
    color = mix(color, whiteColor, leftShineFill * 0.8h);
    color = mix(color, whiteColor, rightShineFill * 0.8h);
    
    // MARK: - Cheeks (rosy)
    
    float2 leftCheekPos = float2(-0.12, 0.02);
    float2 rightCheekPos = float2(0.12, 0.02);
    float cheekRadius = 0.035;
    
    float leftCheekDist = sdCircle(uv - leftCheekPos, cheekRadius);
    float rightCheekDist = sdCircle(uv - rightCheekPos, cheekRadius);
    
    half leftCheekFill = fillSDF(leftCheekDist, 0.02) * bodyFill;
    half rightCheekFill = fillSDF(rightCheekDist, 0.02) * bodyFill;
    
    // More visible cheeks when happy
    half cheekIntensity = 0.3h + half(smoothstep(0.5, 1.5, mood)) * 0.3h;
    
    color = mix(color, cheekColor, leftCheekFill * cheekIntensity);
    color = mix(color, cheekColor, rightCheekFill * cheekIntensity);
    
    // MARK: - Mouth
    
    float2 mouthPos = float2(0.0, 0.08);
    float mouthDist = sdMouth(uv, mouthPos, mood, time);
    half mouthFill = fillSDF(mouthDist, 0.003) * bodyFill;
    
    color = mix(color, forestColor, mouthFill);
    
    // MARK: - Arms (only visible in certain moods)
    
    // Left arm - waves in happy mode
    float2 leftShoulderPos = float2(-0.18, 0.1);
    float leftArmAngle = -2.5 + sin(time * 4.0) * 0.3 * smoothstep(0.5, 1.5, mood);
    float leftArmDist = sdArm(uv, leftShoulderPos, leftArmAngle, 0.08, 0.02);
    
    // Right arm - raised in blocking mode
    float2 rightShoulderPos = float2(0.18, 0.1);
    float rightArmAngle = -0.7;
    // Raise arm for blocking
    rightArmAngle = mix(rightArmAngle, -1.8, smoothstep(1.5, 2.0, mood));
    float rightArmDist = sdArm(uv, rightShoulderPos, rightArmAngle, 0.08, 0.02);
    
    // Arm visibility: show in happy and blocking modes
    half armVisibility = half(smoothstep(0.3, 0.8, mood)) * (1.0h - half(smoothstep(2.8, 3.2, mood)));
    
    half leftArmFill = fillSDF(leftArmDist, 0.005);
    half rightArmFill = fillSDF(rightArmDist, 0.005);
    
    color = mix(color, shieldColor, leftArmFill * armVisibility);
    color = mix(color, shieldColor, rightArmFill * armVisibility);
    
    // Hand circles at arm ends
    float2 leftHandPos = leftShoulderPos + float2(cos(leftArmAngle), sin(leftArmAngle)) * 0.08;
    float2 rightHandPos = rightShoulderPos + float2(cos(rightArmAngle), sin(rightArmAngle)) * 0.08;
    
    float leftHandDist = sdCircle(uv - leftHandPos, 0.025);
    float rightHandDist = sdCircle(uv - rightHandPos, 0.025);
    
    half leftHandFill = fillSDF(leftHandDist, 0.003);
    half rightHandFill = fillSDF(rightHandDist, 0.003);
    
    color = mix(color, shieldColor, leftHandFill * armVisibility);
    color = mix(color, shieldColor, rightHandFill * armVisibility);
    
    // MARK: - Sparkles (happy mode only)
    
    half sparkleVisibility = half(smoothstep(0.5, 1.5, mood)) * (1.0h - half(smoothstep(1.5, 2.0, mood)));
    
    // Create multiple sparkles around the mascot
    for (int i = 0; i < 6; i++) {
        float angle = float(i) * 1.047 + time * 2.0; // 60 degrees apart, rotating
        float dist = 0.28 + sin(time * 3.0 + float(i)) * 0.03;
        float2 sparklePos = float2(cos(angle), sin(angle)) * dist;
        
        float sparkleDist = sdCircle(uv - sparklePos, 0.015);
        half sparkleFill = fillSDF(sparkleDist, 0.005);
        
        // Pulsing alpha
        half sparkleAlpha = half(0.5 + 0.5 * sin(time * 5.0 + float(i) * 2.0));
        
        color = mix(color, half4(1.0h, 1.0h, 0.8h, 1.0h), sparkleFill * sparkleAlpha * sparkleVisibility);
    }
    
    // MARK: - ZZZ (sleeping mode)
    
    half sleepVisibility = half(smoothstep(2.5, 3.5, mood));
    
    // Three Z's floating up
    for (int z = 0; z < 3; z++) {
        float zTime = time * 0.5 + float(z) * 0.5;
        float zY = fract(zTime) * 0.3;
        float zX = 0.15 + float(z) * 0.05;
        float zScale = 0.02 + float(z) * 0.008;
        float zAlpha = 1.0 - fract(zTime);
        
        float2 zPos = float2(zX, -0.15 - zY);
        
        // Simple Z shape using line segments
        float z1 = sdSegment(uv - zPos, float2(-zScale, -zScale), float2(zScale, -zScale));
        float z2 = sdSegment(uv - zPos, float2(zScale, -zScale), float2(-zScale, zScale));
        float z3 = sdSegment(uv - zPos, float2(-zScale, zScale), float2(zScale, zScale));
        
        float zDist = min(min(z1, z2), z3) - 0.003;
        half zFill = fillSDF(zDist, 0.002);
        
        color = mix(color, half4(0.6h, 0.6h, 0.8h, 1.0h), zFill * half(zAlpha) * sleepVisibility);
    }
    
    return color;
}

// MARK: - Simple version for icons/thumbnails

[[ stitchable ]]
half4 grootMascotSimple(
    float2 position,
    half4 currentColor,
    float2 size,
    float time
) {
    return grootMascot(position, currentColor, size, time, 0.0, 0.0, sin(time) * 0.5 + 0.5);
}
