//描画用変数
int grid_margin = 20;
int grid_space = 20;

//座標格納用配列(二次元)
//2つとも完全に対応したインデックスを持つが、代表はmatrixXとする
int [][] matrixX = { {} };
int [][] matrixY = { {} };

//座標保護用配列(二次元)
int [][] matrixX_sub = { {} };
int [][] matrixY_sub = { {} };

//テキスト出力用変数
PrintWriter output;



//low以上high以下か判定する関数
boolean inScope(int target,int low,int high){
  if(target >= low && target <= high){
    return true;
  }else{
    return false;
  }
}

//二次元配列の一次元目に空の配列を追加したものを「返す」関数
//Rubyの [] << [] にあたる(「返す」という点が違うが…)
int [][] addArray(int array[][]){
  int [][] copy = new int[array.length + 1][0];
  
  for(int idx_1st = 0; idx_1st < array.length; idx_1st++){
    for(int idx_2nd = 0; idx_2nd < array[idx_1st].length; idx_2nd++){
      copy[idx_1st] = append(copy[idx_1st], array[idx_1st][idx_2nd]);
    }
  }
  
  return copy;
  //参照渡しだと思ってたら変更できなかった　append等も「返す」仕様だから仕方ない
  //なんで一次元目だとappendもconcatもできないんだよファックするぞ
  //ArrayList？知らない子ですね
}

//ディープ・コピーしたものを「返す」関数
//ディープ・コピーをサポートする
int [][] deep_copy(int [][] array){
  int [][] copy = new int[array.length][0];
  for(int idx_1st = 0; idx_1st < array.length; idx_1st++){
    for(int idx_2nd = 0; idx_2nd < array[idx_1st].length; idx_2nd++){
      copy[idx_1st] = append(copy[idx_1st], array[idx_1st][idx_2nd]);
    }
  }
  return copy;
}

//一次元目の尻の配列に、要素が存在するかどうか判定する関数
boolean idxExist(int [][] array){
  if(array[array.length - 1].length != 0){
    return true;
  }else{
    return false;
  }
  //クソッタレshortenめ、インデックスが不正になることをまるで考えてない！
}



void mousePressed(){
  
  //左クリックなら座標追加、始点と同じ座標なら一次元目に空配列を追加
  if(mouseButton == LEFT){
    for(int w = grid_margin; w <= width - grid_margin; w += grid_space){
      for(int h = grid_margin; h <= height - grid_margin; h += grid_space){
        if(inScope(mouseX, w - 5, w + 5) && inScope(mouseY, h - 3, h + 3)){
          matrixX[matrixX.length - 1] = append(matrixX[matrixX.length - 1], w);
          matrixY[matrixY.length - 1] = append(matrixY[matrixY.length - 1], h);
          if(w == matrixX[matrixX.length - 1][0] && h == matrixY[matrixY.length - 1][0] && matrixX[matrixX.length - 1].length != 1){
            matrixX = addArray(matrixX);
            matrixY = addArray(matrixY);
          }
        }
      }
    }
  //右クリックなら座標削除
  //既に完成したピースは削除不可能
  }else if(mouseButton == RIGHT && idxExist(matrixX)){
    matrixX[matrixX.length - 1] = shorten(matrixX[matrixX.length - 1]);
    matrixY[matrixY.length - 1] = shorten(matrixY[matrixY.length - 1]);
  }
}

void keyPressed(){
  //txt出力及び終了
  //「未完成」或いは「選択中」のピースは書き込まれない
  //データでは閉じないので、二次元目の最後は書き込まない
  if(key == 'q'){
    save("puzzle.png");
    for(int idx_1st = 0; idx_1st < matrixX.length - 1; idx_1st++){
      for(int idx_2nd = 0; idx_2nd < matrixX[idx_1st].length - 1; idx_2nd++){
        output.print((matrixX[idx_1st][idx_2nd] - grid_margin) / grid_space);
        output.print(" ");
        output.print((matrixY[idx_1st][idx_2nd] - grid_margin) / grid_space);
        if(idx_2nd != matrixX[idx_1st].length - 2){
          output.print(" ");
        }
      }
      output.println("");
    }
    output.flush();
    output.close();
    exit();
  //座標全消去
  }else if(key == 'r'){
    matrixX = new int [1][0];
    matrixY = new int [1][0];
  //現時点での座標を全て保護
  }else if(key == 'c'){
    matrixX_sub = deep_copy(matrixX);
    matrixY_sub = deep_copy(matrixY);
  //保護した座標を全て復活
  }else if(key == 'v'){
    matrixX = deep_copy(matrixX_sub);
    matrixY = deep_copy(matrixY_sub);
  }
}

void setup(){
  size(400,400);
  background(0);
  stroke(255);
  fill(255);
  output = createWriter("puzzle.txt");
}

void draw(){
  background(0);
  
  //グリッドを描画
  for(int w = grid_margin; w <= width - grid_margin; w += grid_space){
    for(int h = grid_margin; h <= height - grid_margin; h += grid_space){
      fill(255);
      stroke(255);
      ellipse(w, h, 2, 2);
      //頂点なら緑のサークルを
      for(int idx_1st = 0; idx_1st < matrixX.length; idx_1st++){
        for(int idx_2nd = 0; idx_2nd < matrixX[idx_1st].length; idx_2nd++){
          if(w == matrixX[idx_1st][idx_2nd] && h == matrixY[idx_1st][idx_2nd]){
            noFill();
            stroke(0, 255, 0);
            ellipse(w, h, 20, 20);
          }
        }
      }
      //現在の始点には赤いサークルを
      if(idxExist(matrixX)){
        if(w == matrixX[matrixX.length - 1][0] && h == matrixY[matrixY.length - 1][0]){
          noFill();
          stroke(255, 0, 0);
          ellipse(w, h, 20, 20);
        }
      }
      //選択されているなら黄色いサークルを
      if(inScope(mouseX, w - 5, w + 5) && inScope(mouseY, h - 3, h + 3)){
        noFill();
        stroke(255, 255, 0);
        ellipse(w, h, 20, 20);
      }
    }
  }
  
  fill(255);
  stroke(255);
  
  //線を描画
  for(int idx_1st = 0; idx_1st < matrixX.length; idx_1st++){
    if(idx_1st != matrixX.length - 1){
      fill(255, 255 / 2);
      beginShape();
    }else{
      noFill();
      beginShape();
    }
    for(int idx_2nd = 0; idx_2nd < matrixX[idx_1st].length; idx_2nd++){  
      vertex(matrixX[idx_1st][idx_2nd], matrixY[idx_1st][idx_2nd]);
    }
    if(idx_1st == matrixX.length - 1){
      vertex(mouseX, mouseY);
    }
    endShape();
  }
  
}

//メモ
//Array = Array はシャロー・コピーになる
//配列関数は二次元配列をサポートしない
//createWriterは実行された時点で同名ファイルを空にする