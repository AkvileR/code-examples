//general values
color buttonColor=color(255),buttonHighlight=color(88, 136, 204);
int buttonSize[] = {300,100},tileS=12,col,row,id=0,currentLevel=1;
int buttonX=330,playY=250,editY=400,scale=3;
int gridX,gridY;
float textS=80;
boolean overPlay=false,overEdit=false;

//map and platforms
Table table;
int[][] map;
PImage tilemap;
PImage[] imgArr;
int[][] pl;
Platform[][] plat;

//screens
boolean editorScreen=false,titleScreen=true,playScreen=false,endScreen=false,menuScreen=false;
FrameObject camera,gameWorld;

//player
boolean left=false,right=false,up=false;
Player p;

void setup() {
  size(1000, 700);
  tilemap = loadImage("blacknwhite.png");
  loadMap(1);
  fillArr();
}

void fillArr(){
  col=tilemap.width/tileS;
  row=tilemap.height/tileS;
  imgArr = new PImage[col*row];
  for(int i=0;i<row;++i){
     for(int j=0;j<col;++j){
     imgArr[i*col+j]=tilemap.get(j*tileS,i*tileS,tileS,tileS);
   }
  }
}

void loadMap(int n){
  switch(n){
    case 1: 
      table = loadTable("map1.csv");
      break;
    case 2:
      table = loadTable("map2.csv");
      break;
    case 3:
      table = loadTable("map3.csv");
      break;
  }
  gridY = table.getRowCount();
  gridX = table.getColumnCount();
  map = new int[gridY][gridX];
  for(int i=0;i<gridY;++i){
    for(int j=0;j<gridX;++j){
      map[i][j]= table.getInt(i,j);
    }
  }
}

void saveMap(){
  gridY = table.getRowCount();
  gridX = table.getColumnCount();
  table = new Table();
  for(int i=0;i<gridY;++i)table.addRow();
  for(int j=0;j<gridX;++j)table.addColumn();
  for(int i=0;i<gridY;++i){
    for(int j=0;j<gridX;++j){
      table.setInt(i,j,map[i][j]);
 }}
 switch(currentLevel){
   case 1:
     saveTable(table,"map1.csv");
     break;
   case 2:
     saveTable(table,"map2.csv");
     break;
   case 3:
     saveTable(table,"map3.csv");
     break;
 }
}

void drawMap(){
  for(int i=0;i<gridY;++i){
   for(int j=0;j<gridX;++j){
     int tempx = i*tileS*scale;
     int tempy = j*tileS*scale;
     image(imgArr[map[i][j]],tempy,tempx,tileS*scale,tileS*scale);
   }}
}

//0-background,1-platform,2-death,3-next level
void loadPlatforms(){
  for(int i=0;i<gridY;++i){
   for(int j=0;j<gridX;++j){
     if((map[i][j]>10 && map[i][j]<16)
       || (map[i][j]>18 && map[i][j]<24)
       || (map[i][j]>27 && map[i][j]<32) || map[i][j]>34){
         pl[i][j]=0;
      } else pl[i][j]=1;
     if(map[i][j]==21||map[i][j]==22)pl[i][j]=1;
     if(map[i][j]==11) pl[i][j]=3;
     if(map[i][j]==19) pl[i][j]=2;
   }
 }
   plat = new Platform[gridY][gridX];
   for(int i=0;i<gridY;++i){
     for(int j=0;j<gridX;++j){
       plat[i][j] = new Platform(j*tileS*scale,i*tileS*scale,tileS*scale,tileS*scale,pl[i][j]);
   }
  }
}

void draw(){
  if(titleScreen){
    update(mouseX,mouseY);
    title();
  }
  if(editorScreen) editor(); 
  if(endScreen){ 
    playScreen=false;
    end();
  }
  if(menuScreen){
    menu();
  }
  if(playScreen){
    background(0);
    p.update();

    for(int i=0;i<gridY;++i){
     for(int j=0;j<gridX;++j){
       if(plat[i][j].type!=0){
           p.collisionSide=collisions(p,plat[i][j]);
           if(p.collisionSide!="none"){
             switch(plat[i][j].type){
               case 2:
                 play(currentLevel);
                 break;
               case 3:
                 if(currentLevel==3) endScreen=true;
                 else play(currentLevel+1);
                 break;
           }}
           p.checkPlatforms();
    }}}
    
    camera.x = floor(p.x+(p.w/2)-(camera.w/2));
    camera.y = floor(p.y+(p.y/2)-(camera.h/2));
    if(camera.x<gameWorld.x) camera.x=gameWorld.x;
    if(camera.y<gameWorld.y) camera.y=gameWorld.y;
    if(camera.x+camera.w > gameWorld.x+gameWorld.w) camera.x=gameWorld.x+gameWorld.w-camera.w;
    if(camera.y+camera.h>gameWorld.h) camera.y = gameWorld.h-camera.h;  
    translate(-camera.x,-camera.y);
    
    drawMap();
    p.display();
  }
}

void update(int x, int y){
  if(x>=buttonX && x<=buttonX+buttonSize[0] &&
     y>=playY && y<= playY+buttonSize[1]){
     overPlay=true;
     overEdit=false;
  }else if(x>=buttonX && x<=buttonX+buttonSize[0] &&
     y>=editY && y<= editY+buttonSize[1]){
       overPlay=false; 
       overEdit=true;
  }else {
    overPlay=overEdit=false;
  }
}
void drawPlay(){
  rect(buttonX,playY,buttonSize[0],buttonSize[1]);
  fill(0);
  text("Play",buttonX+textS,playY+textS);
}
void drawEdit(){
  rect(buttonX,editY,buttonSize[0],buttonSize[1]);
  fill(0);
  text("Edit",buttonX+textS,editY+textS);
}

void mouseReleased(){
  if(titleScreen && overPlay){
    titleScreen=false;
    playScreen=true;
    play(1);
  }
  if(titleScreen && overEdit){
    titleScreen=false;
    editorScreen=true;
  }
}
void mousePressed(){
  if(editorScreen && mouseX<=width/scale && mouseY<=height/scale){
    int tempx= mouseX/(width/scale/col);
    int tempy= mouseY/(height/scale/row);
    id = tempy*col+tempx;
  }
  if(editorScreen && mouseY>width/scale && mouseY<=width/scale+gridY*tileS*scale
    && mouseX<gridX*tileS*scale){
    int tempx= mouseX/(tileS*scale);
    int tempy= (mouseY-width/scale)/(tileS*scale);
    map[tempy][tempx]=id;
   }
}

void keyPressed(){
   switch(key){
     case 'm':
       editorScreen=false;
       playScreen=false;
       endScreen=false;
       titleScreen=false;
       menuScreen=true;
       break;
     case 'b':
       if(editorScreen) saveMap();
       loadMap(1);
       currentLevel=1;
       editorScreen=false;
       playScreen=false;
       endScreen=false;
       menuScreen=false;
       titleScreen=true;
       scale=3;
       cursor();
       break;
     case '1':
       if(editorScreen){
         saveMap();
         currentLevel=1;
         loadMap(1);
       }
       break;
     case '2':
       if(editorScreen){
         saveMap();
         currentLevel=2;
         loadMap(2);
       }
       break;
     case '3':
       if(editorScreen){
         saveMap();
         currentLevel=3;
         loadMap(3);
       }
       break;
     case 'a':
       left=true;
       break;
     case 'd':
       right=true;
       break;
     case 32:  //space
       up=true;
       break;
   }  
}
void keyReleased(){
  switch(key){
    case 'a':
      left=false;
      break;
    case 'd':
      right=false;
      break;
    case 32:  //space
      up=false;
      break;
  }
}

void title(){
  titleScreen=true;
  background(0);
  fill(255);
  textSize(128);
  text("Escape",300,200);
  textSize(textS);
  if(overPlay){
      fill(buttonHighlight);
      drawPlay();
      fill(buttonColor);
      drawEdit();
    }else if(overEdit){
      fill(buttonColor);
      drawPlay();
      fill(buttonHighlight);
      drawEdit();
    }else{
      fill(buttonColor);
      drawPlay();
      fill(buttonColor);
      drawEdit();
    }
}
void editor(){
  background(0);
  image(tilemap,0,0,width/scale,height/scale);
  noFill();
  stroke(255);
  for(int i=0;i<gridY;++i){
   for(int j=0;j<gridX;++j){
     int tempx = j*tileS*scale;
     int tempy = i*tileS*scale+width/scale;
     image(imgArr[map[i][j]],tempx,tempy,tileS*scale,tileS*scale);
     rect(tempx,tempy,tileS*scale,tileS*scale);
   }
  }
  image(imgArr[id],mouseX+tileS,mouseY+tileS,tileS*scale,tileS*scale);
}

void play(int n){
  background(0);
  noCursor();
  loadMap(n);
  scale=6;
  p = new Player();
  pl = new int[gridY][gridX];
  loadPlatforms();
  gameWorld = new FrameObject(0,0,gridX*tileS*scale,gridY*tileS*scale);
  camera = new FrameObject(0,0,width,height);
  camera.x=(gameWorld.x+gameWorld.w/2)-camera.w/2;
  camera.y=(gameWorld.y+gameWorld.h/2)-camera.h/2;
  currentLevel=n;
}

void end(){
  background(0);
  fill(255);
  textSize(128);
  text("The end",300,200);
}

void menu(){
  background(0);
  fill(255);
  textSize(128);
  text("Menu",300,200);
}

String collisions(Player r1, Platform r2){
    float dx = (r1.x+r1.w/2) - (r2.x+r2.w/2);
    float dy = (r1.y+r1.h/2) - (r2.y+r2.h/2);
  
    float combinedHalfWidths = (r1.w/2) + r2.halfWidth;
    float combinedHalfHeights = (r1.w/2) + r2.halfHeight;
  
    if (abs(dx) < combinedHalfWidths) {
      if (abs(dy) < combinedHalfHeights) {
        float overlapX = combinedHalfWidths - abs(dx);
        float overlapY = combinedHalfHeights - abs(dy);
        if (overlapX >= overlapY){
          if (dy > 0) {
            r1.y += overlapY;
            return "top";
          }else{
            r1.y -= overlapY;
            return "bottom";
          }
        }else{
          if (dx > 0) {
            r1.x += overlapX;
            return "left";
          }else{
            r1.x -= overlapX;
            return "right";
          }
        }
      }else{
        //collision failed on the y axis
        return "none";
      }
    }else{
      //collision failed on the x axis
      return "none";
    }
}
