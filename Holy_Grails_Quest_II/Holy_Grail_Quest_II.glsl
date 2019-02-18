@UNIFORMS

uniform vec3(buffer:target=0) iResolution;
uniform float(time) iTime;
uniform vec4(mouse:2pos_2click) iMouse;
uniform vec4(date) iDate;
uniform int(frame) iFrame;
uniform float(deltatime) iTimeDelta;

uniform float(0:1:0) uShape;
uniform int(0:20:10) iters;
uniform float(0:50:20) limit;
uniform vec3(0:5:1) scale;

@FRAGMENT

//based on effie shader : https://www.shadertoy.com/view/MtfGWM

//another holy grail candidate from msltoe found here:
//http://www.fractalforums.com/theory/choosing-the-squaring-formula-by-location

//I have altered the formula to make it continuous but it still creates the same nice julias - eiffie

#define time iTime
#define size iResolution

vec3 C,mcol;
bool bColoring=false;
#define pi 3.14159
float DE(in vec3 p)
{
	p *= scale;
	float dr=1.0,r=length(p);
	//C=p;
	for(int i=0;i<iters;i++)
	{
		if(r>limit)break;
		dr=dr*2.0*r;
		float psi = abs(mod(atan(p.z,p.y)+pi/8.0,pi/4.0)-pi/8.0);
		p.yz=vec2(cos(psi),sin(psi))*length(p.yz);
		vec3 p2=p*p;
		p=vec3(vec2(p2.x-p2.y,2.0*p.x*p.y)*(1.0-p2.z/(p2.x+p2.y+p2.z)),
			2.0*p.z*sqrt(p2.x+p2.y))+C;	
		r=length(p);
		if(bColoring && i==3)mcol=p;
	}
	return min(log(r)*r/max(dr,1.0),1.0);
}

float rnd(vec2 c){return fract(sin(dot(vec2(1.317,19.753),c))*413.7972);}
float rndStart(vec2 fragCoord){
	return 0.5+0.5*rnd(fragCoord.xy+vec2(time*217.0));
}
float shadao(vec3 ro, vec3 rd, float px, vec2 fragCoord){//pretty much IQ's SoftShadow
	float res=1.0,d,t=2.0*px*rndStart(fragCoord);
	for(int i=0;i<4;i++){
		d=max(px,DE(ro+rd*t)*1.5);
		t+=d;
		res=min(res,d/t+t*0.1);
	}
	return res;
}

vec3 Julia(float t)
{
	t=mod(t,5.0);
	if(t<1.0)return vec3(-0.8,0.0,0.0);
	if(t<2.0)return vec3(-0.8,0.62,0.41);
	if(t<3.0)return vec3(-0.8,1.0,-0.69);
	if(t<4.0)return vec3(0.5,-0.84,-0.13);
	return vec3(0.0,1.0,-1.0);
}

void Init()
{
	mcol = vec3(0);
	float tim=uShape*15.0 + iTime;
	if(mod(tim,15.0)<5.0)
		C=mix(Julia(tim-1.0),Julia(tim),smoothstep(0.0,1.0,fract(tim)*5.0));
	else 
		C=vec3(-cos(tim),cos(tim)*abs(sin(tim*0.3)),-0.5*abs(-sin(tim)));
}

float getDF(vec3 p)
{
	return DE(p);
}

vec3 getNor(vec3 pos, float prec)
{
	vec3 eps = vec3( prec, 0., 0. );
	vec3 nor = vec3(
	    getDF(pos+eps.xyy) - getDF(pos-eps.xyy),
	    getDF(pos+eps.yxy) - getDF(pos-eps.yxy),
	    getDF(pos+eps.yyx) - getDF(pos-eps.yyx) );
	return normalize(nor);
}

vec3 getColor(vec3 p, vec3 n)
{
	bColoring=true;float d=DE(p);bColoring=false;
	vec3 lc=vec3(1.0,0.9,0.8),sc=sqrt(abs(sin(mcol)));
	return 2.0*lc*sc;
}

