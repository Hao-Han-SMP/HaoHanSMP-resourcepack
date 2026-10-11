// Origins of six 256x256 face tiles in model_shader_1.png; face order is
// +X,-X,+Y,-Y,+Z,-Z, packed three columns by two rows per celestial body.
const float LS_TAU=6.28318530718;
const vec2 LS_MERCURY=vec2(0,0);
const vec2 LS_VENUS=vec2(768,0);
const vec2 LS_EARTH=vec2(1536,0);
const vec2 LS_MARS=vec2(2304,0);
const vec2 LS_JUPITER=vec2(0,512);
const vec2 LS_SATURN=vec2(768,512);
const vec2 LS_URANUS=vec2(1536,512);
const vec2 LS_NEPTUNE=vec2(2304,512);
const vec2 LS_PLUTO=vec2(0,1024);
const vec2 LS_MOON=vec2(768,1024);
const vec2 LS_EUROPA=vec2(1536,1024);
const vec2 LS_GLACIO=vec2(2304,1024);
const vec2 LS_JBP=vec2(0,1536);
const vec2 LS_SIN=vec2(768,1536);
const vec2 LS_DARKEARTH=vec2(1536,1536);
const vec2 LS_UNKNOWN=vec2(2304,1536);
const vec2 LS_NIGHT_EARTH=vec2(0,2048);
const vec2 LS_NIGHT_VENUS=vec2(768,2048);
const vec2 LS_RING_JUPITER=vec2(0,2560);
const vec2 LS_RING_SATURN_1=vec2(256,2560);
const vec2 LS_RING_SATURN_2=vec2(512,2560);
const vec2 LS_RING_URANUS=vec2(768,2560);
const vec2 LS_RING_NEPTUNE=vec2(1024,2560);

vec3 lsSampleFace(vec2 origin,int face,vec2 uv){
    vec2 ts=vec2(textureSize(Sampler0,0));
    ivec2 corner=ivec2(floor(texCoord0*ts));
    ivec2 tile=ivec2(face%3,face/3)*256;
    ivec2 tileMin=corner+ivec2(origin)+tile;
    ivec2 tileMax=tileMin+ivec2(255);
    // Bilinear filtering at level zero keeps each sample inside its own face
    // tile: no mip bleeding from neighboring atlas faces and no hard texel
    // stepping when a planet is large on screen.
    vec2 pixel=clamp(uv,vec2(0.0),vec2(1.0))*255.0;
    ivec2 p=ivec2(floor(pixel));
    vec2 f=fract(pixel);
    ivec2 p00=clamp(tileMin+p,tileMin,tileMax);
    ivec2 p10=clamp(tileMin+p+ivec2(1,0),tileMin,tileMax);
    ivec2 p01=clamp(tileMin+p+ivec2(0,1),tileMin,tileMax);
    ivec2 p11=clamp(tileMin+p+ivec2(1,1),tileMin,tileMax);
    vec3 a=mix(texelFetch(Sampler0,p00,0).rgb,texelFetch(Sampler0,p10,0).rgb,f.x);
    vec3 b=mix(texelFetch(Sampler0,p01,0).rgb,texelFetch(Sampler0,p11,0).rgb,f.x);
    return mix(a,b,f.y);
}
vec3 lsSampleRing(vec2 origin,vec2 uv,float ringHeight){
    ivec2 corner=ivec2(floor(texCoord0*vec2(textureSize(Sampler0,0))));
    ivec2 tileMin=corner+ivec2(origin);
    ivec2 tileMax=tileMin+ivec2(255,int(ringHeight)-1);
    vec2 pixel=clamp(uv,vec2(0.0),vec2(1.0))*vec2(255.0,ringHeight-1.0);
    ivec2 p=ivec2(floor(pixel+0.5));
    return texelFetch(Sampler0,clamp(tileMin+p,tileMin,tileMax),0).rgb;
}
float lsHash(vec3 p){p=fract(p*0.3183099+vec3(0.1));p*=17.0;return fract(p.x*p.y*p.z*(p.x+p.y+p.z));}
float lsNoise(vec3 p){vec3 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);
    return mix(mix(mix(lsHash(i),lsHash(i+vec3(1,0,0)),f.x),mix(lsHash(i+vec3(0,1,0)),lsHash(i+vec3(1,1,0)),f.x),f.y),
      mix(mix(lsHash(i+vec3(0,0,1)),lsHash(i+vec3(1,0,1)),f.x),mix(lsHash(i+vec3(0,1,1)),lsHash(i+vec3(1,1,1)),f.x),f.y),f.z);}
vec3 lsProceduralSky(vec3 d){
    vec3 col=vec3(0.0015,0.002,0.008);
    // Multi-scale dust and star clouds follow a warped galactic great circle.
    // The wide glow and narrow bright lane keep the band from reading as a stripe.
    vec3 galacticNormal=normalize(vec3(-0.42,0.83,0.36));
    float galacticLatitude=dot(d,galacticNormal);
    float warp=0.025*sin(d.x*4.9+d.z*3.7)+0.013*sin(d.z*10.0-d.x*6.2);
    float wideBand=exp(-pow((galacticLatitude+warp)/0.235,2.0));
    float brightLane=exp(-pow((galacticLatitude+warp)/0.095,2.0));
    float cloudA=lsNoise(d*16.0+vec3(3.7,1.2,-5.1));
    float cloudB=lsNoise(d*43.0+vec3(-8.3,2.4,6.2));
    float cloudC=lsNoise(d*112.0+vec3(11.1,-4.8,2.7));
    float nebula=cloudA*0.50+cloudB*0.34+cloudC*0.16;
    float dustLane=lsNoise(d*31.0+vec3(9.1,6.4,-3.2));
    float rift=lsNoise(d*57.0+vec3(-4.6,8.1,2.3));
    vec3 coreDirection=vec3(0.31,0.18,-0.93);
    coreDirection=normalize(coreDirection-galacticNormal*dot(coreDirection,galacticNormal));
    float core=pow(max(dot(d,coreDirection),0.0),5.5);
    float cloudShape=smoothstep(0.32,0.72,nebula);
    float filaments=pow(max(nebula-0.42,0.0)*1.72,1.35);
    float dustMask=smoothstep(0.43,0.73,dustLane)*0.48+smoothstep(0.58,0.82,rift)*0.34;
    float cloudField=wideBand*(0.035+cloudShape*0.30)+brightLane*(0.045+filaments*0.72);
    cloudField*=1.0-clamp(dustMask,0.0,0.78);
    vec3 galacticColor=mix(vec3(0.12,0.16,0.25),vec3(0.48,0.36,0.23),clamp(core*0.82+cloudA*0.12,0.0,1.0));
    col+=cloudField*galacticColor*1.9;
    col+=brightLane*core*vec3(0.20,0.15,0.10)*0.72;
    col-=brightLane*dustMask*vec3(0.030,0.027,0.022);
    col+=exp(-pow((galacticLatitude-warp-0.29)/0.13,2.0))*cloudB*vec3(0.018,0.025,0.044);

    vec3 cell=floor(d*1350.0);float hash=lsHash(cell);
    float starThreshold=0.9987-brightLane*(0.00025+cloudA*0.00015);
    float star=step(starThreshold,hash),bright=step(0.99992,lsHash(cell+19.1));
    float phase=lsHash(cell+7.3)*LS_TAU,speed=0.75+lsHash(cell+13.7)*0.75;
    float twinkle=0.94+0.06*sin(GameTime*1200.0*speed+phase);
    float brightPhase=lsHash(cell+31.9)*LS_TAU;
    float brightTwinkle=0.96+0.04*sin(GameTime*1200.0*(0.65+lsHash(cell+47.2))+brightPhase);
    vec3 starColor=mix(vec3(1.0,0.76,0.58),vec3(0.62,0.76,1.0),lsHash(cell+63.8));
    col+=star*twinkle*starColor+bright*brightTwinkle*vec3(1.0,0.84,0.65)*1.5;

    // Rare, deterministic meteors: each 90-second slot has its own stable seed;
    // only a small fraction of slots fire, and each streak lasts about a second.
    float skySeconds=GameTime*1200.0;
    float meteorSlot=floor(skySeconds/90.0);
    float meteorTime=mod(skySeconds,90.0);
    float meteorSeed=lsHash(vec3(meteorSlot,17.3,29.1));
    if(meteorSeed<0.22&&meteorTime<1.0){
        float azimuth=lsHash(vec3(meteorSlot,41.7,5.2))*LS_TAU;
        float elevation=lsHash(vec3(meteorSlot,8.6,73.4))*1.6-0.8;
        vec3 meteorStart=normalize(vec3(cos(azimuth)*cos(elevation),sin(elevation),sin(azimuth)*cos(elevation)));
        vec3 reference=abs(meteorStart.y)<0.9?vec3(0.0,1.0,0.0):vec3(1.0,0.0,0.0);
        vec3 meteorAxis=normalize(cross(reference,meteorStart));
        vec3 meteorSide=normalize(cross(meteorStart,meteorAxis));
        float denominator=max(dot(d,meteorStart),0.12);
        vec2 meteorPoint=vec2(dot(d,meteorAxis),dot(d,meteorSide))/denominator;
        float head=-0.12+0.24*meteorTime;
        float behind=head-meteorPoint.x;
        float tailMask=smoothstep(0.0,0.008,behind)*(1.0-smoothstep(0.045,0.065,behind));
        float tail=exp(-pow(meteorPoint.y/0.0022,2.0))*tailMask;
        float headGlow=exp(-pow((meteorPoint.x-head)/0.009,2.0)-pow(meteorPoint.y/0.004,2.0));
        col+=vec3(0.46,0.64,1.0)*tail*0.75+vec3(1.0,0.91,0.75)*headGlow*1.5;
    }
    return col;
}
vec3 lsRotateX(vec3 v,float a){float c=cos(a),s=sin(a);return vec3(v.x,c*v.y-s*v.z,s*v.y+c*v.z);}
vec3 lsRotateZ(vec3 v,float a){float c=cos(a),s=sin(a);return vec3(c*v.x-s*v.y,s*v.x+c*v.y,v.z);}
vec3 lsRotateY(vec3 v,float angle){float c=cos(angle),s=sin(angle);return vec3(c*v.x+s*v.z,v.y,-s*v.x+c*v.z);}
// Body attitude is independent from its position. Spin is around local Y;
// tilt.x/tilt.z set the natural, fixed axial inclination in world space.
vec3 lsBodyToWorld(vec3 v,vec3 tilt,float spin){return lsRotateZ(lsRotateX(lsRotateY(v,spin),tilt.x),tilt.z);}
vec3 lsWorldToBody(vec3 v,vec3 tilt,float spin){return lsRotateY(lsRotateX(lsRotateZ(v,-tilt.z),-tilt.x),-spin);}
bool lsCubeHit(vec3 ray,vec3 center,float halfSize,float spin,vec3 tilt,out float hitT,out int face,out vec2 uv,out vec3 normal){
    vec3 origin=lsWorldToBody(-center,tilt,spin);
    vec3 direction=lsWorldToBody(ray,tilt,spin);
    vec3 safeD=vec3(abs(direction.x)<1e-6?(direction.x<0.0?-1e-6:1e-6):direction.x,abs(direction.y)<1e-6?(direction.y<0.0?-1e-6:1e-6):direction.y,abs(direction.z)<1e-6?(direction.z<0.0?-1e-6:1e-6):direction.z);
    vec3 a=(-vec3(halfSize)-origin)/safeD,b=(vec3(halfSize)-origin)/safeD;
    float nearT=max(max(min(a.x,b.x),min(a.y,b.y)),min(a.z,b.z));
    float farT=min(min(max(a.x,b.x),max(a.y,b.y)),max(a.z,b.z));
    if(farT<max(nearT,0.0))return false;
    hitT=max(nearT,0.0);if(hitT<=0.0)return false;
    vec3 hit=origin+direction*hitT,absHit=abs(hit),localNormal;
    if(absHit.x>=absHit.y&&absHit.x>=absHit.z){localNormal=vec3(sign(hit.x),0,0);face=hit.x>0.0?0:1;uv=hit.zy;}
    else if(absHit.y>=absHit.z){localNormal=vec3(0,sign(hit.y),0);face=hit.y>0.0?2:3;uv=hit.xz;}
    else{localNormal=vec3(0,0,sign(hit.z));face=hit.z>0.0?4:5;uv=hit.xy;}
    uv=clamp(uv/(2.0*halfSize)+0.5,vec2(0.006),vec2(0.994));
    normal=normalize(lsBodyToWorld(localNormal,tilt,spin));return true;
}
// Test a ray from a point in space against a body's rotated cube. Used for
// self-shadowing on ring planes, where the planet must block the Sun.
bool lsRayHitsBody(vec3 rayOrigin,vec3 rayDirection,vec3 center,float halfSize,float spin,vec3 tilt){
    vec3 origin=lsWorldToBody(rayOrigin-center,tilt,spin);
    vec3 direction=lsWorldToBody(rayDirection,tilt,spin);
    vec3 safeD=vec3(abs(direction.x)<1e-6?(direction.x<0.0?-1e-6:1e-6):direction.x,abs(direction.y)<1e-6?(direction.y<0.0?-1e-6:1e-6):direction.y,abs(direction.z)<1e-6?(direction.z<0.0?-1e-6:1e-6):direction.z);
    vec3 a=(-vec3(halfSize)-origin)/safeD,b=(vec3(halfSize)-origin)/safeD;
    float nearT=max(max(min(a.x,b.x),min(a.y,b.y)),min(a.z,b.z));
    float farT=min(min(max(a.x,b.x),max(a.y,b.y)),max(a.z,b.z));
    return farT>max(nearT,0.002);
}
float lsRingSelfShadow(vec3 ringPoint,vec3 bodyCenter,float halfSize,float spin,vec3 tilt,vec3 lightPosition){
    vec3 toLight=normalize(lightPosition-ringPoint);
    vec3 origin=ringPoint+toLight*0.002;
    if(lsRayHitsBody(origin,toLight,bodyCenter,halfSize,spin,tilt))return 0.24;
    // A slightly expanded occluder approximates the Sun's finite angular size
    // and gives a narrow penumbra around the hard cube shadow.
    if(lsRayHitsBody(origin,toLight,bodyCenter,halfSize*1.045,spin,tilt))return 0.58;
    return 1.0;
}
vec3 lsTiltFromAxis(vec3 axis){
    axis=normalize(axis);
    return vec3(asin(clamp(axis.z,-1.0,1.0)),0.0,atan(-axis.x,axis.y));
}
vec3 lsTiltAwayFromView(vec3 baseTilt,vec3 bodyCenter,float maxFacing){
    vec3 axis=normalize(lsBodyToWorld(vec3(0.0,1.0,0.0),baseTilt,0.0));
    vec3 view=normalize(bodyCenter);
    float facing=dot(axis,view);
    if(abs(facing)>maxFacing){
        vec3 across=axis-view*facing;
        if(dot(across,across)<1e-6)across=normalize(cross(view,vec3(0.0,1.0,0.0)));
        else across=normalize(across);
        axis=normalize(across*sqrt(1.0-maxFacing*maxFacing)+view*sign(facing)*maxFacing);
    }
    return lsTiltFromAxis(axis);
}
// Procedural, pixel-banded Minecraft-style ring material. The texture is
// generated in polar ring coordinates; angular cells drift to suggest orbiting
// particles while radial lanes and gaps remain stable.
vec4 lsProceduralRing(vec2 uv,float seconds,float seed,vec3 baseColor,float gapCenter,float gapWidth,float opacity){
    float radial=clamp(uv.y,0.0,1.0);
    float angle=fract(uv.x+seconds*(0.010+seed*0.002));
    float radialCell=floor(radial*220.0);
    float angularCell=floor(angle*512.0);
    float grain=lsHash(vec3(radialCell,angularCell,seed));
    float strata=mod(floor(radial*8.0),4.0);
    float zone=mix(0.56,1.0,step(0.5,strata));
    zone*=mix(0.72,0.90,step(2.5,strata));
    float bandNoise=lsNoise(vec3(radialCell*0.055,seed,2.1));
    float fineLanes=step(0.16,fract(radial*54.0+bandNoise*0.18));
    float lane=zone*mix(0.30,1.0,fineLanes)*mix(0.86,1.0,grain);
    float gap=1.0-smoothstep(gapWidth*0.35,gapWidth,abs(radial-gapCenter));
    lane*=1.0-gap*0.97;
    float edge=smoothstep(0.0,0.012,radial)*(1.0-smoothstep(0.988,1.0,radial));
    float alpha=clamp(lane*edge*opacity,0.0,0.98);
    vec3 color=baseColor*(0.82+grain*0.18)*(0.84+0.16*step(0.5,fract(radial*24.0)));
    return vec4(color,alpha);
}
// Angular cube helper retained for the procedural Sun.
bool lsCubeSurface(vec3 ray,vec3 center,float halfAngle,float spin,vec3 tilt,out int face,out vec2 uv,out vec3 normal){
    float t;return lsCubeHit(ray,normalize(center),tan(halfAngle)/(1.0+tan(halfAngle)),spin,tilt,t,face,uv,normal);
}
vec3 lsFacePoint(int face,vec2 uv){
    vec2 p=uv*2.0-1.0;
    if(face==0)return vec3(1.0,p.y,p.x);
    if(face==1)return vec3(-1.0,p.y,p.x);
    if(face==2)return vec3(p.x,1.0,p.y);
    if(face==3)return vec3(p.x,-1.0,p.y);
    if(face==4)return vec3(p.x,p.y,1.0);
    return vec3(p.x,p.y,-1.0);
}
bool lsRingHit(vec3 ray,vec3 center,vec3 ringNormal,float innerRadius,float outerRadius,float halfThickness,float rotation,out float hitT,out vec2 ringUv){
    float denom=dot(ray,ringNormal);
    if(abs(denom)<1e-5)return false;
    // A small finite slab keeps rings visible at shallow viewing angles.
    hitT=(dot(center,ringNormal)-sign(denom)*halfThickness)/denom;
    if(hitT<=0.0)return false;
    vec3 offset=ray*hitT-center;
    vec3 radial=offset-ringNormal*dot(offset,ringNormal);
    float radius=length(radial);
    if(radius<innerRadius||radius>outerRadius)return false;
    vec3 ref=abs(ringNormal.y)<0.95?vec3(0,1,0):vec3(1,0,0);
    vec3 axisX=normalize(cross(ref,ringNormal)),axisZ=normalize(cross(ringNormal,axisX));
    float angle=atan(dot(radial,axisZ),dot(radial,axisX))+rotation;
    ringUv=vec2(fract(angle/LS_TAU+0.5),(radius-innerRadius)/(outerRadius-innerRadius));
    return true;
}
vec3 lsRingNormal(float pitchDegrees,float rollDegrees){
    float p=radians(pitchDegrees),r=radians(rollDegrees);
    return normalize(vec3(sin(r)*cos(p),cos(r)*cos(p),sin(p)));
}
// The ring textures are transparent square-outline plates (not polar/radial
// strips). Intersect their square footprint and pass planar UVs unchanged so
// each authored square contour stays square in world space.
bool lsSquareRingHit(vec3 ray,vec3 center,vec3 ringNormal,float halfExtent,float halfThickness,float rotation,out float hitT,out vec2 ringUv){
    float denom=dot(ray,ringNormal);
    if(abs(denom)<1e-5)return false;
    hitT=(dot(center,ringNormal)-sign(denom)*halfThickness)/denom;
    if(hitT<=0.0)return false;
    vec3 offset=ray*hitT-center;
    vec3 ref=abs(ringNormal.y)<0.95?vec3(0,1,0):vec3(1,0,0);
    vec3 axisX=normalize(cross(ref,ringNormal)),axisZ=normalize(cross(ringNormal,axisX));
    float c=cos(rotation),s=sin(rotation);
    vec2 planar=vec2(dot(offset,axisX),dot(offset,axisZ));
    planar=mat2(c,-s,s,c)*planar;
    if(max(abs(planar.x),abs(planar.y))>halfExtent)return false;
    ringUv=clamp(planar/(2.0*halfExtent)+0.5,vec2(0.0),vec2(1.0));
    return true;
}
// Keplerian orbit in an ecliptic frame. GameTime advances one simulated Earth
// day per Minecraft day; the fixed phase is an epoch because shader packs do
// not receive a cumulative in-game year/date uniform.
vec3 lsOrbitPosition(float semiMajorAxis,float eccentricity,float periodDays,float meanAnomaly0,float inclination,float ascendingNode,float periapsis){
    float meanAnomaly=mod(meanAnomaly0+LS_TAU*GameTime/periodDays,LS_TAU);
    float eccentricAnomaly=meanAnomaly;
    for(int i=0;i<5;i++){
        eccentricAnomaly-=(eccentricAnomaly-eccentricity*sin(eccentricAnomaly)-meanAnomaly)/(1.0-eccentricity*cos(eccentricAnomaly));
    }
    float x=semiMajorAxis*(cos(eccentricAnomaly)-eccentricity);
    float z=semiMajorAxis*sqrt(1.0-eccentricity*eccentricity)*sin(eccentricAnomaly);
    float cp=cos(periapsis),sp=sin(periapsis);
    vec2 peri=vec2(cp*x-sp*z,sp*x+cp*z);
    float ci=cos(inclination),si=sin(inclination);
    vec3 inclined=vec3(peri.x,peri.y*si,peri.y*ci);
    float cn=cos(ascendingNode),sn=sin(ascendingNode);
    return vec3(cn*inclined.x-sn*inclined.z,inclined.y,sn*inclined.x+cn*inclined.z);
}
vec3 lsPlanetLight(vec3 albedo,vec3 normal,vec3 lightDir,float ambient){return albedo*(ambient+(1.0-ambient)*max(dot(normal,lightDir),0.0));}
