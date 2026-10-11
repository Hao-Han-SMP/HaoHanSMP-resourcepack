// Lunar sky simulation. DayTime controls the apparent sky rotation, while
// GameTime supplies the resource-pack shader's repeating sub-day animation phase.
float lsSimDays=GameTime;
// DayTime is supplied by the mod's model shader and changes immediately with
// /time set. Rotate the complete celestial sphere around its vertical axis so
// the sky follows Minecraft's apparent daily motion.
float lsDayPhase=fract(DayTime());
vec3 lsSkyRay=lsRotateY(worldDirection,(lsDayPhase-0.25)*LS_TAU);
// The pack only receives a one-day phase, not cumulative world age. Preserve
// real relative spin rates for fast rotators and give slow rotators one visible
// cycle per Minecraft day so Mercury, Venus and the ice giants do not look frozen.
float lsSpinDay=fract(DayTime())*2.5;
float spinSun=LS_TAU*lsSpinDay/max(25.05,1.0);
float spinMercury=LS_TAU*lsSpinDay/max(58.646,1.0);
// Venus is retrograde because its near-inverted pole is in tiltVenus; the
// positive local-axis spin combines with that pole direction to move backward.
float spinVenus=LS_TAU*lsSpinDay/max(243.025,1.0);
float spinEarth=LS_TAU*lsSpinDay/max(0.9972696,1.0);
float spinMars=LS_TAU*lsSpinDay/max(1.025957,1.0);
float spinJupiter=LS_TAU*lsSpinDay/max(9.925/24.0,1.0);
float spinSaturn=LS_TAU*lsSpinDay/max(10.656/24.0,1.0);
float spinUranus=LS_TAU*lsSpinDay/max(17.24/24.0,1.0);
float spinNeptune=LS_TAU*lsSpinDay/max(16.11/24.0,1.0);
float spinPluto=LS_TAU*lsSpinDay/max(6.3872,1.0);
vec3 tiltMercury=vec3(0.0005,0.0,0.3);
vec3 tiltVenus=vec3(3.094,0.0,1.2);
vec3 tiltEarth=vec3(0.409,0.0,0.8);
vec3 tiltMars=vec3(0.440,0.0,2.1);
vec3 tiltJupiter=vec3(0.055,0.0,1.4);
vec3 baseTiltSaturn=vec3(0.467,0.0,1.0);
vec3 baseTiltUranus=vec3(1.706,0.0,0.85);
vec3 baseTiltNeptune=vec3(0.494,0.0,2.4);
vec3 tiltPluto=vec3(2.087,0.0,1.0);
vec3 tiltMoon=vec3(0.117,0.0,1.8);
vec3 tiltSun=vec3(0.126,0.0,0.2);
vec3 col=lsProceduralSky(lsSkyRay);
// Approximate JPL Kepler elements evaluated for 2026-10-11. The epoch remains
// fixed because this resource-pack shader receives no cumulative world-age/year
// uniform. /time set changes the apparent daily sky rotation above, not the
// planets' multi-year heliocentric orbital epoch.
float lsAuScale=40000.0;
// 1 AU is 40,000 shader units; the Moon is about 384,400 km from Earth.
// A shared 4x base display factor preserves body-radius ratios. Small remote
// planets get a minimum angular size below so their cubes remain observable.
float lsEarthRadius=40000.0*6371.0/149597870.7*4.0;
vec3 earthCenter=normalize(vec3(-2500.0,200.0,1500.0))*103.0;
vec3 earthOrbit=lsOrbitPosition(1.00000017,0.01672183,365.256,radians(276.2161),radians(-0.0041),radians(-5.1772),radians(108.1924));
vec3 mercuryOrbit=lsOrbitPosition(0.38709843,0.20564229,87.969,radians(235.7786),radians(7.0040),radians(48.3069),radians(29.1935));
vec3 venusOrbit=lsOrbitPosition(0.72332095,0.00675032,224.701,radians(238.2319),radians(3.3979),radians(76.5996),radians(55.1832));
vec3 marsOrbit=lsOrbitPosition(1.52371269,0.09338961,686.980,radians(104.0074),radians(1.8499),radians(49.6413),radians(-73.4377));
vec3 jupiterOrbit=lsOrbitPosition(5.20247252,0.04858416,4332.59,radians(112.5970),radians(1.2978),radians(100.3277),radians(-86.0040));
vec3 saturnOrbit=lsOrbitPosition(9.54149062,0.05542245,10759.2,radians(284.3117),radians(2.4955),radians(113.5730),radians(-20.5666));
vec3 uranusOrbit=lsOrbitPosition(19.18792471,0.04685325,30688.5,radians(255.5024),radians(0.7725),radians(73.9779),radians(98.4810));
vec3 neptuneOrbit=lsOrbitPosition(30.06954478,0.00895658,60182.0,radians(316.7116),radians(1.7701),radians(131.7847),radians(-85.1004));
vec3 plutoOrbit=lsOrbitPosition(39.482,0.2488,90560.0,radians(53.46),radians(17.14),radians(110.30),radians(113.77));
// Rotate the ecliptic frame to keep the current Sun direction in the same
// visible part of this skybox while preserving the relative ephemeris layout.
float lsSkyFrameRotation=LS_TAU*0.5;
vec3 mercuryCenter=earthCenter+lsRotateY((mercuryOrbit-earthOrbit)*lsAuScale,lsSkyFrameRotation);
vec3 venusCenter=earthCenter+lsRotateY((venusOrbit-earthOrbit)*lsAuScale,lsSkyFrameRotation);
vec3 marsCenter=earthCenter+lsRotateY((marsOrbit-earthOrbit)*lsAuScale,lsSkyFrameRotation);
vec3 jupCenter=earthCenter+lsRotateY((jupiterOrbit-earthOrbit)*lsAuScale,lsSkyFrameRotation);
vec3 satCenter=earthCenter+lsRotateY((saturnOrbit-earthOrbit)*lsAuScale,lsSkyFrameRotation);
vec3 uranusCenter=earthCenter+lsRotateY((uranusOrbit-earthOrbit)*lsAuScale,lsSkyFrameRotation);
vec3 nepCenter=earthCenter+lsRotateY((neptuneOrbit-earthOrbit)*lsAuScale,lsSkyFrameRotation);
// Keep ringed worlds' poles turned partly away from the current lunar view.
// This preserves a natural axial tilt while preventing the ring plane from
// appearing as a foreshortened square aimed straight at the player.
vec3 tiltSaturn=lsTiltAwayFromView(baseTiltSaturn,satCenter,0.30);
vec3 tiltUranus=lsTiltAwayFromView(baseTiltUranus,uranusCenter,0.30);
vec3 tiltNeptune=lsTiltAwayFromView(baseTiltNeptune,nepCenter,0.30);
vec3 plutoCenter=earthCenter+lsRotateY((plutoOrbit-earthOrbit)*lsAuScale,lsSkyFrameRotation);
float europaOrbitAngle=LS_TAU*lsSimDays/3.551;
vec3 europaCenter=jupCenter+vec3(cos(europaOrbitAngle),0.0,sin(europaOrbitAngle))*179.0;
vec3 sunCenter=earthCenter+lsRotateY(-earthOrbit*lsAuScale,lsSkyFrameRotation);
vec3 sunDir=normalize(sunCenter);
float earthRadius=lsEarthRadius*1.12;
float mercuryRadius=max(lsEarthRadius*0.383,length(mercuryCenter)*0.0030);
float venusRadius=max(lsEarthRadius*0.949,length(venusCenter)*0.0030);
float marsRadius=max(lsEarthRadius*0.532,length(marsCenter)*0.0030);
float jupiterRadius=max(lsEarthRadius*11.21,length(jupCenter)*0.0030);
float saturnRadius=max(lsEarthRadius*9.45,length(satCenter)*0.0030);
float uranusRadius=max(lsEarthRadius*4.01,length(uranusCenter)*0.0030);
float neptuneRadius=max(lsEarthRadius*3.88,length(nepCenter)*0.0030);
float plutoRadius=max(lsEarthRadius*0.186,length(plutoCenter)*0.0018);
float europaRadius=max(lsEarthRadius*0.245,length(europaCenter)*0.0005);

// The Sun intentionally remains a cube with a procedural plasma surface.
{
    int face;vec2 uv;vec3 normal;
    float sunAngle=acos(clamp(dot(lsSkyRay,sunDir),-1.0,1.0));
    if(lsCubeSurface(lsSkyRay,sunDir,atan(lsEarthRadius*109.2/length(sunCenter)),spinSun,tiltSun,face,uv,normal)){
        float grain=lsNoise(vec3(uv*18.0,spinSun));
        float detail=lsNoise(vec3(uv*55.0,spinSun*1.7));
        float bands=0.88+0.12*sin((uv.x+uv.y*0.35)*55.0+spinSun);
        vec3 plasma=mix(vec3(1.0,0.20,0.015),vec3(1.0,0.82,0.18),clamp(0.45+grain*0.75+detail*0.25,0.0,1.0));
        col=plasma*bands*2.4;
    }
    col+=vec3(1.0,0.24,0.035)*0.10*exp(-sunAngle/0.084);
}

float nearestHit=1.0e30;
int nearestId=-1;
float earthHit=1.0e30;
{
    float t;int face;vec2 uv;vec3 n;
    if(lsCubeHit(lsSkyRay,earthCenter,earthRadius,spinEarth,tiltEarth,t,face,uv,n)&&t<nearestHit){
        nearestHit=t;nearestId=2;earthHit=t;
        vec3 light=normalize(sunCenter-earthCenter);
        vec3 base=lsSampleFace(LS_EARTH,face,uv);
        col=lsPlanetLight(base,n,light,0.22);
    }
}

// Each body gets its own physical center, half-size, surface map and spin rate.
#define LS_DRAW_CUBE(bodyId,center,halfSize,atlas,spin,tilt,ambient) \
{ float t;int face;vec2 uv;vec3 n;vec3 bodyCenter=center;if(lsCubeHit(lsSkyRay,bodyCenter,halfSize,spin,tilt,t,face,uv,n)&&t<nearestHit){nearestHit=t;nearestId=bodyId;vec3 bodyLight=normalize(sunCenter-bodyCenter);col=lsPlanetLight(lsSampleFace(atlas,face,uv),n,bodyLight,ambient);} }
LS_DRAW_CUBE(1,mercuryCenter,mercuryRadius,LS_MERCURY,spinMercury,tiltMercury,0.22)
{
    vec3 center=venusCenter;float t;int face;vec2 uv;vec3 n;
    if(lsCubeHit(lsSkyRay,center,venusRadius,spinVenus,tiltVenus,t,face,uv,n)&&t<nearestHit){
        nearestHit=t;nearestId=1;vec3 light=normalize(sunCenter-center);
        vec3 base=lsSampleFace(LS_VENUS,face,uv);
        col=lsPlanetLight(base,n,light,0.24);
    }
}
LS_DRAW_CUBE(3,marsCenter,marsRadius,LS_MARS,spinMars,tiltMars,0.22)
{
    vec3 center=jupCenter;float t;int face;vec2 uv;vec3 n;
    if(lsCubeHit(lsSkyRay,center,jupiterRadius,spinJupiter,tiltJupiter,t,face,uv,n)&&t<nearestHit){
        nearestHit=t;nearestId=4;vec3 light=normalize(sunCenter-center);
        col=lsPlanetLight(lsSampleFace(LS_JUPITER,face,uv),n,light,0.28);
    }
}
LS_DRAW_CUBE(5,satCenter,saturnRadius,LS_SATURN,spinSaturn,tiltSaturn,0.26)
LS_DRAW_CUBE(6,uranusCenter,uranusRadius,LS_URANUS,spinUranus,tiltUranus,0.26)
LS_DRAW_CUBE(7,nepCenter,neptuneRadius,LS_NEPTUNE,spinNeptune,tiltNeptune,0.24)
LS_DRAW_CUBE(8,plutoCenter,plutoRadius,LS_PLUTO,spinPluto,tiltPluto,0.22)
LS_DRAW_CUBE(9,europaCenter,europaRadius,LS_EUROPA,spinJupiter,vec3(0.002,0.0,0.8),0.24)
#undef LS_DRAW_CUBE

// Larger cube shells avoid z-fighting. Each layer has its own gentle spin.
if(nearestId==2){
    float t;int face;vec2 uv;vec3 n;
    if(lsCubeHit(lsSkyRay,earthCenter,earthRadius*1.006,spinEarth,tiltEarth,t,face,uv,n)&&t<=earthHit+2.0){
        vec3 p=lsFacePoint(face,uv);float time=GameTime*1200.0;
        float broad=lsNoise(p*3.8+vec3(time*0.010,0.0,time*0.007));
        float detail=lsNoise(p*8.5+vec3(-time*0.014,time*0.006,0.0));
        float alpha=smoothstep(0.54,0.73,broad*0.72+detail*0.28)*0.46;
        vec3 light=normalize(sunCenter-earthCenter);
        col=mix(col,vec3(0.78,0.86,0.95)*(0.32+0.68*max(dot(n,light),0.0)),alpha);
    }
}
// Gas-giant bands and Venus detail come from their authored cube-face maps.
// Avoid adding procedural cloud noise over those maps: it looked like blotchy
// duplicate textures and concealed the original artwork.

float surfaceDepth=nearestHit;
float ringT;vec2 ringUv;
// Cosmos has no explicit asteroid-belt entry in solar_system.json, so add a
// restrained procedural belt around the Sun, between the inner/outer system.
if(lsRingHit(lsSkyRay,sunCenter,vec3(0.0,1.0,0.0),88000.0,128000.0,110.0,0.0,ringT,ringUv)&&ringT<surfaceDepth){
    vec2 cells=floor(ringUv*vec2(1600.0,44.0));
    float grains=lsHash(vec3(cells,4.2));
    float clumps=step(0.982,grains)*0.24+step(0.998,lsHash(vec3(cells+19.1,8.4)))*0.34;
    float clouds=lsNoise(vec3(ringUv.x*31.0,ringUv.y*9.0,2.7));
    float dust=0.012+0.024*clouds+clumps;
    col+=vec3(0.32,0.25,0.18)*dust;
}

// Procedural ring disks: no atlas UVs, stretched masks or square outlines.
float ringSeconds=GameTime*1200.0;
vec3 jupNormal=lsBodyToWorld(vec3(0.0,1.0,0.0),tiltJupiter,0.0);
if(lsRingHit(lsSkyRay,jupCenter,jupNormal,jupiterRadius*1.28,jupiterRadius*1.9,jupiterRadius*0.012,ringSeconds*0.0008,ringT,ringUv)&&ringT<surfaceDepth){
    vec3 ringPoint=lsSkyRay*ringT;float shadow=lsRingSelfShadow(ringPoint,jupCenter,jupiterRadius,spinJupiter,tiltJupiter,sunCenter);
    vec4 ring=lsProceduralRing(ringUv,ringSeconds,1.7,vec3(0.50,0.43,0.34),0.58,0.035,0.30);
    col=mix(col,ring.rgb*shadow,ring.a);
}
vec3 satNormal=lsBodyToWorld(vec3(0.0,1.0,0.0),tiltSaturn,0.0);
if(lsRingHit(lsSkyRay,satCenter,satNormal,saturnRadius*1.12,saturnRadius*2.45,saturnRadius*0.012,ringSeconds*0.0005,ringT,ringUv)&&ringT<surfaceDepth){
    vec3 ringPoint=lsSkyRay*ringT;float shadow=lsRingSelfShadow(ringPoint,satCenter,saturnRadius,spinSaturn,tiltSaturn,sunCenter);
    vec4 ring=lsProceduralRing(ringUv,ringSeconds,2.4,vec3(0.77,0.67,0.48),0.55,0.045,0.90);
    col=mix(col,ring.rgb*shadow,ring.a);
}
vec3 uranusNormal=lsBodyToWorld(vec3(0.0,1.0,0.0),tiltUranus,0.0);
if(lsRingHit(lsSkyRay,uranusCenter,uranusNormal,uranusRadius*1.45,uranusRadius*1.8,uranusRadius*0.006,ringSeconds*0.0007,ringT,ringUv)&&ringT<surfaceDepth){
    vec3 ringPoint=lsSkyRay*ringT;float shadow=lsRingSelfShadow(ringPoint,uranusCenter,uranusRadius,spinUranus,tiltUranus,sunCenter);
    vec4 ring=lsProceduralRing(ringUv,ringSeconds,3.1,vec3(0.32,0.30,0.26),0.46,0.025,0.78);
    col=mix(col,ring.rgb*shadow,ring.a);
}
vec3 nepNormal=lsBodyToWorld(vec3(0.0,1.0,0.0),tiltNeptune,0.0);
if(lsRingHit(lsSkyRay,nepCenter,nepNormal,neptuneRadius*1.35,neptuneRadius*2.4,neptuneRadius*0.006,ringSeconds*0.0009,ringT,ringUv)&&ringT<surfaceDepth){
    vec3 ringPoint=lsSkyRay*ringT;float shadow=lsRingSelfShadow(ringPoint,nepCenter,neptuneRadius,spinNeptune,tiltNeptune,sunCenter);
    vec4 ring=lsProceduralRing(ringUv,ringSeconds,4.3,vec3(0.31,0.30,0.28),0.62,0.02,0.48);
    col=mix(col,ring.rgb*shadow,ring.a);
}

fragColor=applyFog(vec4(col,1.0),0.25);
