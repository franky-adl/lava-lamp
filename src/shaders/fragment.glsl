// original code in tsl: https://github.com/phobon/raymarching-tsl

uniform float uTime;
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;

// SDF for sphere
float sdSphere(vec3 p, float r) {
    return length(p) - r;
}

// Smooth minimum function
float smin(float a, float b, float k) {
    float h = max(k - abs(a - b), 0.0) / k;
    return min(a, b) - h * h * k * 0.25;
}

// Scene SDF
float sdf(vec3 pos) {
    float scale = 0.3;
    float yOffset = -0.3;
    float sphere = sdSphere(
        pos + vec3(0.0, yOffset + scale * sin(uTime * 0.4) * 1.5, 0.0),
        scale * 0.8
    );

    float secondSphere = sdSphere(
        pos + vec3(scale * sin(uTime * 0.25) * 0.8, yOffset + scale * sin(uTime * 0.5) * 2.5, 0.0),
        scale * 0.5
    );

    float thirdSphere = sdSphere(
        pos + vec3(scale * sin(3.14 + uTime * 0.2) * 0.4, yOffset + scale * sin(3.14 + uTime * 0.5) * 2.0, scale * sin(4.0 + uTime * 0.2) * 0.4),
        scale * 0.65
    );
    
    return smin(smin(secondSphere, sphere, 0.3), thirdSphere, 0.3);
}

// Calculate normal using gradient
vec3 calcNormal(vec3 p) {
    float eps = 0.0001;
    vec2 h = vec2(eps, 0.0);
    return normalize(vec3(
        sdf(p + h.xyy) - sdf(p - h.xyy),
        sdf(p + h.yxy) - sdf(p - h.yxy),
        sdf(p + h.yyx) - sdf(p - h.yyx)
    ));
}

// Lighting calculation
vec4 lighting(vec3 ro, vec3 r) {
    vec3 normal = calcNormal(r);
    vec3 viewDir = normalize(ro - r);
    float opacity = 1.0;
    
    // Ambient light
    vec3 ambient = vec3(2.0, 1.0, 0.5);
    vec3 ballsColor = vec3(1.0, 0.9, 0.1);
    float ballsAmbient = 0.0;
    
    // Diffuse lighting
    vec3 lightDir = normalize(vec3(0.0, -1.0, 0.0));
    vec3 lightDir2 = normalize(vec3(-1.0, 0.5, 0.0));
    vec3 lightColor = vec3(1.0, 0.9, 0.1);
    float dp = max(max(0.0, dot(lightDir, normal)), dot(lightDir2, normal));
    vec3 diffuse = dp * lightColor;
    vec3 diffuseShell = pow(abs(min(vPosition.y - 1.0, 0.0)), 2.0) * lightColor;
    
    // Phong specular
    vec3 ph = normalize(reflect(-lightDir, normal));
    vec3 ph2 = normalize(reflect(-lightDir2, normal));
    float phongValue = pow(max(max(0.0, dot(viewDir, ph)), dot(viewDir, ph2)), 32.0);
    
    // Handle back-facing surfaces: don't light up anything that is not the balls
    if (dot(viewDir, normal) < 0.0) {
        phongValue = 0.0;
        diffuse = vec3(0.0);
        opacity = 0.2;
    } else {
        ballsAmbient = 1.0;
        opacity = 1.0;
    }
    
    vec3 specular = vec3(phongValue);
    
    // Fresnel effect
    float fresnel = pow(1.0 - max(0.0, dot(viewDir, normal)), 2.0);
    float fresnelShell = pow(1.0 - max(0.0, dot(viewDir, vNormal)), 3.0);
    specular *= fresnel;
    
    // Combine lighting components
    vec3 finalLighting = ambient * 0.1;
    finalLighting += ballsColor * ballsAmbient * 2.0;
    finalLighting += diffuse * 1.2;
    finalLighting += diffuseShell * 5.5;
    vec3 finalColor = vec3(0.1) * finalLighting;

    // add specular and container fresnel on top of the basic lighting
    finalColor += specular;
    finalColor += lightColor * fresnelShell * 0.5;
    
    return vec4(finalColor, opacity);
}

void main() {
    // Calculate ray direction from camera towards the current pixel
    vec3 rayOrigin = cameraPosition;
    vec3 rayDirection = normalize(vPosition - rayOrigin);
    
    // Raymarching
    float t = 0.0;
    vec3 ray = rayOrigin + rayDirection * t;
    
    for (int i = 0; i < 80; i++) {
        float d = sdf(ray);
        t += d;
        ray = rayOrigin + rayDirection * t;
        
        if (d < 0.005) {
            break;
        }
        
        if (t > 50.0) {
            break;
        }
    }
    
    gl_FragColor = lighting(rayOrigin, ray);
}