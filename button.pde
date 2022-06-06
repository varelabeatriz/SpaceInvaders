class Button{
int x,y,w,h;
color c;
String t;

Button( int _x, int _y, int _w, int _h, color _c, String _t){
  x = _x;
  y = _y;
  w = _w;
  h = _h;
  c = _c;
  t = _t;
}

void show(){
 fill(c);
 stroke(0, 128, 0);
 rect(x,y,w,h,15);
}

}
