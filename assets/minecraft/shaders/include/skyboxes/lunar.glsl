// Lunar sky simulation. DayTime controls the apparent sky rotation, while
// GameTime supplies the resource-pack shader's repeating sub-day animation phase.
float lsSimDays=GameTime;
// Diurnal axial rotation following Minecraft's day/night cycle.
// Reoriented so the celestial sphere rises in the East, arches high across the zenith,
// and sets in the West, mirroring Overworld sun & moon motion.
float lsDayPhase=fract(DayTime());
float lsDayAngle=(lsDayPhase-0.25)*LS_TAU;
vec3 lsSkyRay=lsRotateZ(lsRotateX(worldDirection,radians(16.0)),-lsDayAngle);
// Continuous diurnal axial rotation around each planet's tilted spin axis.
// Combines real-time shader GameTime with DayTime so planets visibly rotate around
// their physical poles even when doDaylightCycle is locked on the server.
float lsContinuousSpin = GameTime * 0.10 + fract(DayTime()) * LS_TAU;
float spinSun = lsContinuousSpin * 0.15;
float spinMercury = lsContinuousSpin * 0.25;
float spinVenus = -lsContinuousSpin * 0.20;
float spinEarth = lsContinuousSpin * 0.65;
float spinMars = lsContinuousSpin * 0.60;
float spinJupiter = lsContinuousSpin * 1.45;
float spinSaturn = lsContinuousSpin * 1.35;
float spinUranus = lsContinuousSpin * 0.85;
float spinNeptune = lsContinuousSpin * 0.90;
float spinPluto = lsContinuousSpin * 0.30;
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
// The Sun is oriented along zenith (+Y) at local noon, rising in East and setting in West.
vec3 sunCenter=vec3(0.0,40000.0,0.0);
vec3 sunDir=normalize(sunCenter);
// Earth is oriented towards the night sky (opposite Sun) with realistic lunar perspective tilt.
vec3 earthCenter=normalize(vec3(0.12,-0.98,0.16))*103.0;

// 3D Celestial Distribution: planets are distributed across distinct quadrants and declinations
// rather than collapsing into a single straight line.
vec3 mercuryCenter=sunCenter*0.90+vec3(9200.0,-5800.0,4400.0);
vec3 venusCenter=sunCenter*0.72+vec3(-21500.0,-11200.0,12600.0);
vec3 marsCenter=vec3(26000.0,-18000.0,-32000.0);
vec3 jupCenter=vec3(82000.0,-68000.0,94000.0);
vec3 satCenter=vec3(-110000.0,-75000.0,85000.0);
vec3 uranusCenter=vec3(-180000.0,45000.0,-210000.0);
vec3 nepCenter=vec3(190000.0,-95000.0,-280000.0);
vec3 plutoCenter=vec3(-240000.0,-160000.0,-220000.0);

// Keep ringed worlds' poles turned partly away from the current lunar view.
// This preserves a natural axial tilt while preventing the ring plane from
// appearing as a foreshortened square aimed straight at the player.
vec3 tiltSaturn=lsTiltAwayFromView(baseTiltSaturn,satCenter,0.30);
vec3 tiltUranus=lsTiltAwayFromView(baseTiltUranus,uranusCenter,0.30);
vec3 tiltNeptune=lsTiltAwayFromView(baseTiltNeptune,nepCenter,0.30);
float europaOrbitAngle=LS_TAU*lsSimDays/3.551;
vec3 europaCenter=jupCenter+vec3(cos(europaOrbitAngle),sin(europaOrbitAngle)*0.38,sin(europaOrbitAngle)*0.92)*179.0;
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

fragColor=vec4(col,1.0);
