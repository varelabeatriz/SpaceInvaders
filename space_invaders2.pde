
import ddf.minim.*;

//Variáveis globais:
int  tela;
Button bt, sair, regras, voltar, comecar,cj,creditos;// declarado o botao
Minim gerenciador;
AudioPlayer somdefundo;
boolean mouseHit(int trgX, int trgY, int trgW, int trgH){
  return(mouseX + 2 >= trgX && mouseX <= trgX + trgW && mouseY + 2 >= trgY && mouseY <= trgY + trgH);
}

Bloco blocos[] = new Bloco[36];
boolean blocoIs[] = new boolean[36];

Alien aliens[] = new Alien[55];
boolean alienIs[] = new boolean[55];

Tiro tiros[] = new Tiro[100];
boolean tiroIs[] = new boolean[100];

PImage textures[] = new PImage[19];
PFont fonte = new PFont();

int playerPos = 0;

int score = 0;
int best = 0;

int lostCycle = 0;
boolean lost = false;

int cycle = 0;
int cyclePos = 0;
int cycleSpeed = 40;

boolean tiro = false;
int tiroX = 0;
int tiroY = 0;

int lives = 3;

boolean aliensRight = true;
int downIterations = 0;
int alienPosX = 76;

boolean over = false;

int delayUfo = 0;
boolean UfoIs = false;
boolean UfoDir = false;
int UfoX = 0;

boolean left = false;
boolean right = false;
boolean up = false;

void setup() {
  size(460, 600);
  chargeData();
  setupBlocos();
  setupAliens();
  best = int(loadStrings("score.txt")[0]);
  playerPos = width/2-13;
  delayUfo = int(1000+random(600));
  gerenciador = new Minim(this);
  somdefundo = gerenciador.loadFile("somdefundo.mp3");
  somdefundo.rewind();
  somdefundo.play();
  bt = new Button(180,290,110,50,180,"JOGAR");
  sair = new Button(180,350,110,50,180,"SAIR");
  regras = new Button(180,410,110,50,180,"REGRAS");
  voltar = new Button(180,490,110,50,180,"VOLTAR");
  cj = new Button(180,430,110,50,180,"COMO JOGAR");
  comecar = new Button(180,430,110,50,180,"COMEÇAR");
  creditos = new Button(180,470,110,50,180,"CREDITOS");
}

void keyPressed() {
  if (keyCode == LEFT) left = true;
  if (keyCode == RIGHT) right = true;
  if (keyCode == UP) up = true;
}

void keyReleased() {
  if (keyCode == LEFT) left = false;
  if (keyCode == RIGHT) right = false;
  if (keyCode == UP) up = false;
}

void draw() {
  background(0);
  if(tela==0){
   menuGame();
  }
  if(tela==1){
   loreGame();
  }
  if(tela==3){
    Regras();
  }
  if(tela==4){
    Creditos();
  }
  if(tela==2){
    if (!lost) {
      image(textures[14], playerPos, 550);
    } else {
      image(textures[11+int((abs(lostCycle)%6)/3)], playerPos-2, 546);
      lostCycle--;
      if (lostCycle == 0 && !over) lost = false;
    }
  for (int i = 0; i < 36; i++) {
    if (blocoIs[i]) {
      image(textures[6+blocos[i].getDamages()], blocos[i].getX(), blocos[i].getY());
      if (!over && tiro && tiroX < blocos[i].getX()+12 && tiroX+2 > blocos[i].getX() && tiroY < blocos[i].getY()+12 && tiroY+6 > blocos[i].getY()) {
        blocos[i].setDamages(blocos[i].getDamages()+1);
        if (blocos[i].getDamages() > 3) blocoIs[i] = false;
        tiro = false;
      }
    }
  }

  int c = 0;

  for (int i = 0; i < 55; i++) {
    if (alienIs[i]) {
      c++;
      if (aliens[i].getExplode() > 0) {
        int delta = aliens[i].getType();
        image(textures[10], aliens[i].getX()-delta, aliens[i].getY());
        aliens[i].setExplode(aliens[i].getExplode()-1);
        if (aliens[i].getExplode() == 0) alienIs[i] = false;
      } else {
        image(textures[aliens[i].getType()*2+cyclePos], aliens[i].getX(), aliens[i].getY());
        int taille = 24;
        if (aliens[i].getType() == 1) taille = 22;
        if (aliens[i].getType() == 2) taille = 16;
        if (!over && tiro && tiroX < aliens[i].getX()+taille && tiroX+2 > aliens[i].getX() && tiroY < aliens[i].getY()+16 && tiroY+6 > aliens[i].getY()) {
          aliens[i].explode();
          if (aliens[i].getType() == 0) score+=10;
          else if (aliens[i].getType() == 1) score+=20;
          else score+=40;
          tiro = false;
        }
        if (!over && random(1000) < 0.2) {
          int ind = 0;
          while (tiroIs[ind]) ind++;
          tiros[ind] = new Tiro(aliens[i].getX()+taille/2-1, aliens[i].getY()+16);
          tiroIs[ind] = true;
        }
      }
    }
  }

  if (c == 0) {
    setupAliens();
    cycleSpeed = 40;
  }

  for (int i = 0; i < 100; i++) {
    if (tiroIs[i]) {
      image(textures[15+tiros[i].getTex()], tiros[i].getX(), tiros[i].getY());
      tiros[i].setTex(tiros[i].getTex()+1);
      if (tiros[i].getTex() > 2) tiros[i].setTex(0);
      tiros[i].setY(tiros[i].getY()+6);
      if (tiros[i].getY() > 590) tiroIs[i] = false;
      for (int j = 0; j < 36; j++) {
        if (blocoIs[j]) {
          if (tiros[i].getX() < blocos[j].getX()+12 && tiros[i].getX()+6 > blocos[j].getX() && tiros[i].getY() < blocos[j].getY()+12 && tiros[i].getY()+10 > blocos[j].getY()) {
            blocos[j].setDamages(blocos[j].getDamages()+1);
            if (blocos[j].getDamages() > 3) blocoIs[j] = false;
            tiroIs[i] = false;
          }
        }
      }
      if (!over && !lost && tiros[i].getX() < playerPos+26 && tiros[i].getX()+6 > playerPos && tiros[i].getY() < 564 && tiros[i].getY()+10 > 550) {
        lost = true;
        lostCycle = 60;
        lives--;
        if (lives == 0) {
          over = true;
          if (score > best) {
            String d[] = {Integer.toString(score)};
            saveStrings("score.txt", d);
            best = score;
          }
        }
        tiroIs[i] = false;
      }
    }
  }

  if (UfoIs) {
    image(textures[18], UfoX, 70);
    if (UfoDir) {
      UfoX++;
      if (UfoX > 460) UfoIs = false;
    } else {
      UfoX--;
      if (UfoX < -32) UfoIs = false;
    }
    if(!over && tiro && tiroX < UfoX+32 && tiroX+2 > UfoX && tiroY < 84 && tiroY+6 > 70){
      score+=int(random(15)+5)*10;
      UfoIs = false;
      tiro = false;
    }
  }
  
  if(!over) delayUfo--;
  if(delayUfo == 0){
    delayUfo = int(1000+random(600));
    UfoIs = true;
    if(random(1) < 0.5){
      UfoDir = true;
      UfoX = -32;
    }
    else{
      UfoDir = false;
      UfoX = 460;
    }
  }

  cycle++;
  if (cycle > cycleSpeed) {
    cycle = 0;
    if (!over) {
      int delta = -4;
      if (aliensRight) delta = 4;
      for (int i = 0; i < 55; i++) {
        if (alienIs[i]) {
          aliens[i].setX(aliens[i].getX()+delta);
        }
      }
      alienPosX+=delta;
      if (aliensRight && alienPosX == 132) {
        downIterations++;
        aliensRight = false;
        for (int i = 0; i < 55; i++) {
          if (alienIs[i]) {
            aliens[i].setY(aliens[i].getY()+4);
          }
        }
        if (cycleSpeed > 5) cycleSpeed-=2;
      }
      if (!aliensRight && alienPosX == 20) {
        downIterations++;
        aliensRight = true;
        for (int i = 0; i < 55; i++) {
          if (alienIs[i]) {
            aliens[i].setY(aliens[i].getY()+4);
          }
        }
        if (cycleSpeed > 5) cycleSpeed-=2;
      }
      if (downIterations > 57) {
        downIterations = 0;
        for (int i = 0; i < 55; i++) {
          if (alienIs[i]) {
            aliens[i].setY(aliens[i].getY()-4*57);
          }
        }
      }
    }
    cyclePos++;
    if (cyclePos > 1) cyclePos = 0;
  }

  if (tiro) {
    image(textures[13], tiroX, tiroY);
    tiroY-=4;
    if (tiroY < 60) tiro = false;
  }

  if (!over && !lost) {
    if (left && playerPos > 30) playerPos-=2;
    if (right && playerPos < width-56) playerPos+=2;

    if (!tiro && up) {
      tiro = true;
      tiroX = playerPos+12;
      tiroY = 544;
    }
  }
  
  if(over){
    fill(0, 200);
    rect(0, 0, width, height);
    textFont(fonte, 50);
    textAlign(CENTER, CENTER);
    fill(255);
    text("GAME OVER", width/2, height/2);
    textFont(fonte, 30);
    text("Score : "+score, width/2, height/2+50);
  }
  else{
    textFont(fonte, 20);
    textAlign(LEFT, UP);
    fill(255);
    text("Score : "+score, 30, 30);
    textAlign(RIGHT, UP);
    text("Best : "+max(best, score), width-30, 30);
    for(int i = 0; i < lives; i++){
      image(textures[14], 187+i*30, 20);
    }
  }
}}

void setupBlocos() {
  int blocoNbre = 0;
  for (int i = 0; i < 21; i++) {
    for (int j = 0; j < 3; j++) {
      if (int(i/3)%2 == 0) {
        blocos[blocoNbre] = new Bloco(104+i*12, 470+j*12);
        blocoIs[blocoNbre] = true;
        blocoNbre++;
      }
    }
  }
}

void setupAliens() {
  int alienNbre = 0;
  for (int i = 0; i < 11; i++) {
    for (int j = 0; j < 5; j++) {
      int type = 0;
      int deltaX = 0;
      if (j == 0) {
        type = 2;
        deltaX = 6;
      } else if (j < 3) {
        type = 1;
        deltaX = 4;
      } else {
        type = 0;
        deltaX = 2;
      }
      aliens[alienNbre] = new Alien(76+i*28+deltaX, 100+j*28, type);
      alienIs[alienNbre] = true;
      alienNbre++;
    }
  }
}
void menuGame(){

background(0,0,0);
fill(0, 128, 0);
textSize(50);
PFont pixelFontTitle = createFont("pixel.ttf", 42);
textFont(pixelFontTitle);
text("SPACE INVADERS",50,150);

//botao Jogar ao ser selecionado
if(mouseHit(bt.x, bt.y, bt.w, bt.h))
if (mousePressed) tela=1;
else bt.c = 255;
else bt.c =0;

//botao Sair ao ser selecionado
if(mouseHit(sair.x, sair.y, sair.w, sair.h))
if (mousePressed) System.exit(0);
else sair.c = 255;
else sair.c =0;

//botao Regras ao ser selecionado
if(mouseHit(regras.x, regras.y, regras.w, regras.h))
if (mousePressed) tela=3;
else regras.c = 255;
else regras.c =0;

//botao Creditos ao ser selecionado
if(mouseHit(creditos.x, creditos.y, creditos.w, creditos.h))
if (mousePressed) tela=4;
else creditos.c = 255;
else creditos.c =0;

bt.show();
sair.show();
regras.show();
creditos.show();
//botao Jogar ao ser selecionado
//mensagem
fill(255);
textSize(20);
text(bt.t, bt.x + bt.w/4,bt.y+ bt.h/1.7);

//mensagem
fill(255);
textSize(20);
text(sair.t, sair.x + sair.w/3,sair.y+ sair.h/1.7);

fill(255);
textSize(20);
text(regras.t, regras.x + regras.w/5,regras.y+ regras.h/1.7);

fill(255);
textSize(20);
text(creditos.t, creditos.x + creditos.w/9,creditos.y+ creditos.h/1.7);

}

void loreGame(){
  background(35,35,35);
  PFont pixelFont = createFont("pixel.ttf", 16);
  textFont(pixelFont);

   float timeSpan = 8000.0;
   float timePosition = millis()/timeSpan % 1;
   float x = lerp(-50, 420, timePosition);
   PImage tv = loadImage("tv.png");
   PImage ufo = loadImage("ufo.png");
   PImage spaceship = loadImage("spaceship.png");

  if (millis() < 8*1000){
     text("Era um dia comum na terra: pássaros cantavam, flores desabrochavam, e você estava na sua casa, deitado no sofá, assistindo Netflix.", 80, 120, 320, 320);
     image(tv, x, 240, width/4, height/4);
  } 

  if ((millis() > 8*1000) && (millis() < 16*1000)){
    text("Quando você olha pela janela e o céu está vermelho. Vários OVNIs aparecem no céu em direção a sua cidade, com armas de alto calibre.", 80, 120, 320, 320);
    image(ufo, x, 240, width/4, height/7);
  }

  if ((millis() > 16*1000) && (millis() < 24*1000)) {
    text("Seu pai é um cientista que já esperava por este momento e designa a missão de acabar com os OVNIs antes que cheguem a terra utilizando uma nave projetada por ele mesmo.", 80, 120, 320, 320);
    image(spaceship, x, 240, width/4, height/4);
  }

  //botao Sair ao ser selecionado
  if(mouseHit(comecar.x, comecar.y, comecar.w, comecar.h))
  if (mousePressed) tela=2;
  else comecar.c = 255;
  else comecar.c = 0;  
  comecar.show();  
  fill(255);
  textSize(20);
  text(comecar.t, comecar.x + comecar.w/7,comecar.y+ comecar.h/1.7);
}

void Regras(){
  //botao Voltar ao ser selecionado
  if(mouseHit(voltar.x, voltar.y, voltar.w, voltar.h))
  if (mousePressed) tela=0;
  else voltar.c = 255;
  else voltar.c =0;
  
  PImage arrows = loadImage("arrows.png");
  textSize(40);
  fill(0, 128, 0);
  text("REGRAS", 160, 50, 320, 320);
  textSize(16);
  fill(255);
  text("1. Utilize as setas para direita e esquerda para mover a nave.", 80, 120, 320, 320);
  text("2. Utilize a seta para cima para atirar.", 80, 180, 320, 320);
  text("3. Desvie do fogo inimigo e salve o planeta.", 80, 240, 320, 320);
  image(arrows, 150, 330, 160, 80);
  voltar.show();
  fill(255);
  textSize(20);
  text(voltar.t, voltar.x + voltar.w/7,voltar.y+ voltar.h/1.7);
}

void Creditos(){
   //botao Voltar ao ser selecionado
  if(mouseHit(voltar.x, voltar.y, voltar.w, voltar.h))
  if (mousePressed) tela=0;
  else voltar.c = 255;
  else voltar.c =0;
  
  textSize(40);
  fill(0, 128, 0);
  text("CREDITOS", 130, 50, 320, 320);
  textSize(18);
  fill(255);
  text("Desenvolvido por:", 80, 120, 320, 320);
   text("Arthur", 80, 180, 320, 320);
   text("Beatriz Souza Varela", 80, 200, 320, 320);
   text("Nathan Tagino Silva", 80, 220, 320, 320);
   text("Vitor de Souza Gotardi", 80, 240, 320, 320);
  voltar.show();
  fill(255);
  textSize(20);
  text(voltar.t, voltar.x + voltar.w/7,voltar.y+ voltar.h/1.7);
}


void chargeData() {
  fonte = createFont("assets/fonte.ttf", 20);

  textures[0] = loadImage("assets/alien 1 1.png");
  textures[1] = loadImage("assets/alien 1 2.png");
  textures[2] = loadImage("assets/alien 2 1.png");
  textures[3] = loadImage("assets/alien 2 2.png");
  textures[4] = loadImage("assets/alien 3 1.png");
  textures[5] = loadImage("assets/alien 3 2.png");

  textures[6] = loadImage("assets/bloco 1.png");
  textures[7] = loadImage("assets/bloco 2.png");
  textures[8] = loadImage("assets/bloco 3.png");
  textures[9] = loadImage("assets/bloco 4.png");

  textures[10] = loadImage("assets/explosion.png");
  textures[11] = loadImage("assets/player morte 1.png");
  textures[12] = loadImage("assets/player morte 2.png");
  textures[13] = loadImage("assets/player tiro.png");
  textures[14] = loadImage("assets/player.png");

  textures[15] = loadImage("assets/tiro 1.png");
  textures[16] = loadImage("assets/tiro 2.png");
  textures[17] = loadImage("assets/tiro 3.png");
  textures[18] = loadImage("assets/ufo.png");
}

class Bloco {
  int x, y;
  int damages = 0;
  Bloco(int x_, int y_) {
    x = x_;
    y = y_;
  }
  int getX() {
    return x;
  }
  int getY() {
    return y;
  }
  int getDamages() {
    return damages;
  }

  void setDamages(int v) {
    damages = v;
  }
}

class Tiro {
  int x, y;
  int tex = 0;

  Tiro(int x_, int y_) {
    x = x_;
    y = y_;
  }
  int getX() {
    return x;
  }
  int getY() {
    return y;
  }
  int getTex() {
    return tex;
  }

  void setX(int v) {
    x = v;
  }
  void setY(int v) {
    y = v;
  }
  void setTex(int v) {
    tex = v;
  }
}

class Alien {
  int x, y, type;
  int explode = 0;
  boolean left = false;

  Alien(int x_, int y_, int type_) {
    x = x_;
    y = y_;
    type = type_;
  }
  void explode() {
    explode = 20;
  }

  int getX() {
    return x;
  }
  int getY() {
    return y;
  }
  int getType() {
    return type;
  }
  int getExplode() {
    return explode;
  }

  void setX(int v) {
    x = v;
  }
  void setY(int v) {
    y = v;
  }
  void setExplode(int v) {
    explode = v;
  }
}
