float random (float2 st)
{
    return frac( sin(dot(st, float2(12.9898,78.233))) * 43758.5453123 );
}

float noise (float2 st)
{
    float2 i = floor(st);
    float2 f = frac(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + float2(1.0, 0.0));
    float c = random(i + float2(0.0, 1.0));
    float d = random(i + float2(1.0, 1.0));

    float2 u = f * f * (3.0 - 2.0 * f);

    return lerp(a, b, u.x) +
                (c - a) * u.y * (1.0 - u.x) +
                (d - b) * u.x * u.y;
}

float fbm (float2 st) {
    // Initial values
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 0.0;
    
    // Loop of octaves
    for (int i = 0; i < 6; i++) {
        value += amplitude * abs(noise(st));
        st *= 2.0;
        amplitude *= 0.5;
    }
    value = abs(1 - value);
    value *= value;
    return value;
}