//ティコ星表をもとに天の川を書くプログラム
int LENGTH;
String[][] csv;
float x,y,alpha,Vmag,r,g,b,size,keido,ido;
int Xarea,Yarea,XWidth = 720*2,YHeight=360*2,gridWidth = 2;
float[][] alphaMap = new float[XWidth][YHeight];
double count = 0;
int DrawStarRate = 1;  //何割の星を表示させるか（デバッグ用）
//等級で透過度を決める際の係数
float alphaBase = 255 / (pow(2.512,9.5));  //何等星まで見えることにするか（今は10等まで）
boolean FullDraw = true;  //星図全体を描画するか

void setup(){
  size(XWidth, YHeight);
  //csvファイル読み込み
  int csvWidth = 0;
  String lines[] = loadStrings("tyc_lite.csv");
  for(int i=1; i< lines.length/DrawStarRate;i++){  //2行目からがデータなので
    String [] chars = split(lines[i], ',');
    if(chars.length>csvWidth){
      csvWidth = chars.length;
    }
  }
  
  //読み込んだファイルを配列に格納（行：星、列：データ）
  csv = new String [lines.length/DrawStarRate][csvWidth];
  LENGTH = lines.length/DrawStarRate;
  println(LENGTH);
  for(int i=1; i<(lines.length/DrawStarRate) - 2;i++){  //2列目からがデータなので
    String[] temp = new String[lines.length/DrawStarRate];
    temp = split(lines[i],',');
    for(int j=0;j<temp.length;j++){csv[i][j] = temp[j];}
    if(i % 10000 == 0){println((int)i);}
  }
}


void draw(){
  count = 0;
  background(0);
  noStroke();
  for(int i=0;i<XWidth;i++){
    for(int j=0;j<YHeight;j++){
      alphaMap[i][j] = 0;
    }
  }
  println("Refresh");
  
  //ひとつずつ星を読み込む
  for(int i=1;i<LENGTH;i++){
    try{
      ido = Float.parseFloat(csv[i][2]);
      keido = Float.parseFloat(csv[i][1]);
      //天の川付近かを判定
      boolean isMilkeyWay = GCCheck(ido,keido);
      if(FullDraw == true || isMilkeyWay == true){
        alpha = Float.parseFloat(csv[i][0]);
        y = (YHeight/2) + ((YHeight/180) * ido) ;
        x = ((XWidth/360) * keido) ;
        //目に見えない星は天の川部分のみ描画
        if((isMilkeyWay == true) || (alpha < 8)){
          Vmag = 255 - (pow(2.512,alpha)) * alphaBase;
          //対応する座標の非透過率を加算（星が重なると明るさも増加）
          //alphaMap[(int)(x)][(int)(y)] +=  Vmag;
          if(alpha < 1.5){
            //alpha等級以下の明るい星を強調表示
            g =0;b=0;size = 5;
          }
          else{g=255;b=255;size = 1.3;}
          fill(255,g,b,Vmag);
          ellipse(x,y,size,size);
          count++;
          if(count % 10000 == 0){println((int)count);}
        }
      }
    }
    catch(Exception e){
      println(count);
    }
    /*
    //読み込んだ星がおおよそ天の川に属しているか判定、属しているなら描画
    boolean isMilkeyWay = GCCheck(ido,keido);
    if(isMilkeyWay){
      y = (YHeight/2) + (YHeight/180) * ido;
      x = (XWidth/2) + (XWidth/360) * keido;
      alpha = Float.parseFloat(csv[i][2]);
      alphaMap[x][y] += (255 - (pow(2.512,alpha) * alphaBase));
      if(alpha >= 0){   //alpha等級より暗い星を描画
        r = Float.parseFloat(csv[i][4]);
        g = Float.parseFloat(csv[i][5]);
        b = Float.parseFloat(csv[i][6]);
        if(alpha < 1.5){
          g =0;b=0;size = 5;
        }
        else{size = 1.3;}
        fill(r,g,b,255 - (pow(2.512,alpha) * alphaBase));
        ellipse(x,y,size,size);
      }
    }
    */
  }
  
  /*for(int i=0;i<XWidth;i++){
    for(int j=0;j<YHeight;j++){
      fill(255,255,255,alphaMap[i][j]);
      ellipse(i,j,1,1);
    }
  }*/
}

boolean GCCheck(float ido, float keido){
  float Gx,Gy,Gz;
  boolean answer;
  //赤経緯度の方向ベクトルを計算
  float Rx = cos(radians(ido)) * cos(radians(keido));
  float Ry = cos(radians(ido)) * sin(radians(keido));
  float Rz = sin(radians(ido));
  
  //回転行列を用いて銀河座標での方向ベクトル成分を計算
  Gx = (-0.0548755 * Rx) + (-0.873437 * Ry) + (-0.483835 * Rz);
  Gy = (0.49411 * Rx) + (-0.44483 * Ry) + (0.746982 * Rz);
  Gz = (-0.867666 * Rx) + (-0.198076 * Ry) + (0.455984 * Rz);
  
  //ベクトル成分から銀緯を計算
  float Gido = degrees((Gz/sqrt(Gx * Gx + Gy * Gy)));
  //緯度が閾値以下なら、天の川付近（所属）の星と判定
  if(abs(Gido) <= 25){answer = true;}
  else{answer = false;}
  
  return answer;
}
