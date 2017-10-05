//描画用変数
final int grid_margin = 10;
final int grid_space = 10;

void setup(){
  size(1020, 660);
  background(0);
  stroke(255);
  fill(255);
  output = createWriter("puzzle.txt");
}

//座標格納用配列(二次元)
//2つとも完全に対応したインデックスを持つが、代表はmatrixXとする
int [][] matrixX = { {} };
int [][] matrixY = { {} };

//座標保護用配列(二次元)
int [][] matrixX_sub = { {} };
int [][] matrixY_sub = { {} };

//座標移動乱数用変数
int addX = 0;
int addY = 0;

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

//二次元配列の一次元目のn番構成要素を削除したものを「返す」変数
//指定したインデックスがない場合動作しない
//Rubyのdelete_atにあたる(「返す」という点が違うが…)
int [][] delete_at(int [][] array, int idx){
  if(idx <= array.length - 1 && idx >= 0){
    int [][] copy = new int[array.length - 1][0];
    for(int idx_1st = 0; idx_1st < array.length; idx_1st++){
      for(int idx_2nd = 0; idx_2nd < array[idx_1st].length; idx_2nd++){
        if(idx_1st < idx){
          copy[idx_1st] = append(copy[idx_1st], array[idx_1st][idx_2nd]);
        }else if(idx_1st > idx){
          copy[idx_1st - 1] = append(copy[idx_1st - 1], array[idx_1st][idx_2nd]);
        }
      }
    }
    return copy;
  }else{
    return array;
  }
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

//一次元目の指定したインデックスの構成配列に、要素が存在するかどうか判定する関数
//指定されたインデックスが不正であればfalseを返す
boolean valueExist(int [][] array, int idx){
  if(idx <= array.length - 1 && idx >= 0){
    if(array[idx].length != 0){
      return true;
    }else{
      return false;
    }
  }else{
    return false;
  }
}



void mousePressed(){
  
  //左クリックなら座標追加、始点と同じ座標なら一次元目に空配列を追加、ピース数を表示
  if(mouseButton == LEFT){
    for(int w = grid_margin; w <= width - grid_margin; w += grid_space){
      for(int h = grid_margin; h <= height - grid_margin; h += grid_space){
        if(inScope(mouseX, w - grid_space / 4, w + grid_space / 4) && inScope(mouseY, h - grid_space / 4, h + grid_space / 4)){
          matrixX[matrixX.length - 1] = append(matrixX[matrixX.length - 1], w);
          matrixY[matrixY.length - 1] = append(matrixY[matrixY.length - 1], h);
          if(w == matrixX[matrixX.length - 1][0] && h == matrixY[matrixY.length - 1][0] && matrixX[matrixX.length - 1].length != 1){
            matrixX = addArray(matrixX);
            matrixY = addArray(matrixY);
            println("ピースが完成しました");
            println("　ピース数：" + (matrixX.length - 2));
          }
        }
      }
    }
  //右クリックなら座標削除
  //既に完成したピースは削除不可能
  }else if(mouseButton == RIGHT && valueExist(matrixX, matrixX.length - 1)){
    matrixX[matrixX.length - 1] = shorten(matrixX[matrixX.length - 1]);
    matrixY[matrixY.length - 1] = shorten(matrixY[matrixY.length - 1]);
  }
}

//二次元配列の1次元目の指定されたインデックスの構成配列の最大値を「返す」関数
//Rubyの…　何だったか忘れたけど「返す」という点が違う
//別に某マックスバリュのステマとかじゃない
int maxValue(int [][] array, int idx){
  int max = 0;
  for(int idx_2nd = 0; idx_2nd < array[idx].length; idx_2nd++){
    if(array[idx][idx_2nd] > max){
      max = array[idx][idx_2nd];
    }
  }
  return max;
}

void keyPressed(){
  //txt出力及び終了
  //「未完成」或いは「選択中」のピースは書き込まれない
  //データではピースを閉じないので、二次元目の最後は書き込まない
  //一次元目0番は枠データだから最後に書き込む
  //相対座標を保ったまま絶対座標を0 <= x <= 100、0 <= y <= 64 の間でランダムに動かす
  if(key == 'q'){
    save("puzzle.png");
    for(int idx_1st = 1; idx_1st < matrixX.length - 1; idx_1st++){
      addX = int(random(0, 101 - (maxValue(matrixX, idx_1st) - grid_margin) / grid_space) );
      addY = int(random(0, 64 - (maxValue(matrixY, idx_1st) - grid_margin) / grid_space) );
      for(int idx_2nd = 0; idx_2nd < matrixX[idx_1st].length - 1; idx_2nd++){
        output.print((matrixX[idx_1st][idx_2nd] - grid_margin) / grid_space + addX);
        output.print(" ");
        output.print((matrixY[idx_1st][idx_2nd] - grid_margin) / grid_space + addY);
        if(idx_2nd != matrixX[idx_1st].length - 2){
          output.print(" ");
        }
      }
      output.println("");
    }
    for(int idx_2nd = 0; idx_2nd < matrixX[0].length - 1; idx_2nd++){
      output.print((matrixX[0][idx_2nd] - grid_margin) / grid_space);
      output.print(" ");
      output.print((matrixY[0][idx_2nd] - grid_margin) / grid_space);
      if(idx_2nd != matrixX[0].length - 2){
        output.print(" ");
      }
    }
    output.flush();
    output.close();
    exit();
  //座標全消去
  }else if(key == 'r'){
    matrixX = new int [1][0];
    matrixY = new int [1][0];
    println("座標を全消去しました");
    println("　ピース数：" + (matrixX.length - 2));
  //現時点での座標を全て保護、保護したピース数を表示
  }else if(key == 'c'){
    println("ピースを保護しました");
    println("　ピース数：" + (matrixX.length - 2));
    matrixX_sub = deep_copy(matrixX);
    matrixY_sub = deep_copy(matrixY);
  //保護した座標を全て復活、現在のピース数を表示
  }else if(key == 'v'){
    matrixX = deep_copy(matrixX_sub);
    matrixY = deep_copy(matrixY_sub);
    println("ピースを復活しました");
    println("　ピース数：" + (matrixX.length - 2));
  //最後に完成したピース・枠を削除、残りピース数を表示
  //完成したピース・枠がない場合機能しない
  }else if(key == 'd'){
    if(matrixX.length != 1){
      matrixX = delete_at(matrixX, matrixX.length - 2);
      matrixY = delete_at(matrixY, matrixY.length - 2);
    }
    println("最後のピースを削除しました");
    println("　ピース数：" + (matrixX.length - 2));
  }
}

void draw(){
  background(0);
  
  //グリッドを描画
  for(int w = grid_margin; w <= width - grid_margin; w += grid_space){
    for(int h = grid_margin; h <= height - grid_margin; h += grid_space){
      fill(255);
      stroke(255);
      ellipse(w, h, 2, 2);
    }
  }
  
  //線・面を描画
  for(int idx_1st = 0; idx_1st < matrixX.length; idx_1st++){
    if(idx_1st != 0  && idx_1st != matrixX.length - 1 ){
      fill(255, 255 / 2);
      stroke(255);
      beginShape();
    }else{
      if(idx_1st == 0){
        stroke(255, 255, 0);
      }else{
        stroke(255);
      }
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
  
  //サークルを描画
  for(int w = grid_margin; w <= width - grid_margin; w += grid_space){
    for(int h = grid_margin; h <= height - grid_margin; h += grid_space){
      //頂点なら緑のサークルを
      for(int idx_1st = 0; idx_1st < matrixX.length; idx_1st++){
        for(int idx_2nd = 0; idx_2nd < matrixX[idx_1st].length; idx_2nd++){
          if(w == matrixX[idx_1st][idx_2nd] && h == matrixY[idx_1st][idx_2nd]){
            noFill();
            stroke(0, 255, 0);
            ellipse(w, h, grid_space, grid_space);
          }
        }
      }
      //現在の始点には赤いサークルを
      if(valueExist(matrixX, matrixX.length - 1)){
        if(w == matrixX[matrixX.length - 1][0] && h == matrixY[matrixY.length - 1][0]){
          noFill();
          stroke(255, 0, 0);
          ellipse(w, h, grid_space, grid_space);
        }
      }
      //選択されているなら黄色いサークルを
      if(inScope(mouseX, w - grid_space / 4, w + grid_space / 4) && inScope(mouseY, h - grid_space / 4, h + grid_space / 4)){
        noFill();
        stroke(255, 255, 0);
        ellipse(w, h, grid_space, grid_space);
      }
    }
  }
  
}

//メモ
//配列 = 配列 はシャロー・コピーになる
//配列関数は多次元配列の最深レベル以外をサポートしない
//createWriterは実行された時点で同名ファイルを空にする