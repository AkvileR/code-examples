public class Player{
    float x, y, w, h, vx, vy,jumpForce;
    float speedX, speedY, maxSpeed,gravity,friction,bounce;
    boolean isOnGround;
    String collisionSide;
    int currentFrame,frameSequence,frameOffset;
    
    Player(){
      //player values
      x=0;
      y=0;
      w=tileS*scale;
      h=tileS*scale;
      maxSpeed=10;
      vx=0;
      vy=0;
      speedX=0;
      speedY=0;
      jumpForce=-15;
      isOnGround=false;
      collisionSide="";
      
      //world values
      gravity= 0.8;
      bounce=-0.4;
      friction=1;  
      
      //animation
      currentFrame=0;
      frameSequence=3;
      frameOffset=0;
      
    }
    void update(){
      //horizontal movement
      if(left && !right){
        speedX=-0.8; 
        friction=1;
      }
      if(!left && right) {
        speedX=0.8;
        friction=1;
      }
      if(!left && !right) speedX=0;
      
      //vertical movement
      if(up && isOnGround){
         vy = jumpForce;
         isOnGround=false;
         friction=1;
      }
      if(!up && !left && !right){
        friction=0.7;
      }
      
      vx+=speedX;
      vy+=speedY;
      
      vx*=friction;
      vy+=gravity;
      
      if(vx>maxSpeed) vx=maxSpeed;
      if(vx<-maxSpeed) vx=-maxSpeed;
      if(vy>3*maxSpeed) vy=3*maxSpeed;
      
      if(abs(vx)<0.2) vx=0;
      
      //move player
      x+=vx;
      y+=vy;
      
      checkBounds();
    }
    
    void checkBounds(){
      if(x<0){
        vx*=bounce;
        x=0;
      }
      if(x+w>gridX*tileS*scale){
        vx*=bounce;
        x=gridX*tileS*scale-w;
      }
      if(y<0){
        vy*=bounce;
        y=0;
      }
      if(y+h>height){
        isOnGround=true;
        vy=0;
        y=height-h;
      }
    }
    void checkPlatforms(){
      if (collisionSide == "bottom" && vy >= 0) {
        if (vy < 1) {
          isOnGround = true;
          vy = 0;
        } else {
          //reduced bounce for floor bounce
          vy *= bounce/2;
        }
      } else if (collisionSide == "top" && vy <= 0) {
        vy = 0;
      } else if (collisionSide == "right" && vx >= 0) {
        vx = 0;
      } else if (collisionSide == "left" && vx <= 0) {
        vx = 0;
      }
      if (collisionSide != "bottom" && vy > 0) {
        isOnGround = false;
      }
    }
    void display(){
      if (abs(vx) > 0)  image(imgArr[currentFrame+4], x, y+10,tileS*scale,tileS*scale);
      else image(imgArr[3], x, y+10,tileS*scale,tileS*scale);
      if (isOnGround) currentFrame = (currentFrame + 1)%frameSequence;
      else currentFrame = 0;
    }
}
