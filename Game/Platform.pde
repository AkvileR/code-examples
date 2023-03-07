class Platform{
  int type;
  float w,h,x,y;
  float halfWidth,halfHeight;
  
  Platform(float _x,float _y, float _w,float _h, int _type){
   w=_w;
   h=_h;
   x=_x;
   y=_y;
   type=_type;
   halfWidth=w/2;
   halfHeight=h/2;
  }
}
