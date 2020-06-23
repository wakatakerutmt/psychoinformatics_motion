%----- 必要な変数を設定 ------
% 実験したいアニメーションのフォルダ名（任意のフォルダーの名前に変える）
name = 'alley_2';

% matlabの実行ファイルを置く場所
workingDir = '/Users/admin/Desktop/matlab/';
% GTのフォルダをworkingDirの配下に置いてその名前
gtDir = 'gt_image/';
gtVectorDir = 'flowfile/';
% アニメーションフォルダの親フォルダをworkingDirの配下に置いてその名前
trainDir = 'target_image/';

% オプティカルフローの軌道を表示する正方形のサイズを決める変数
%  （クリックした点は1pxで小さいのでstep=4と設定することで5×5ピクセルの正方形で表示している）
step=4;

% オプティカルフロー ベクトル表示に関する設定
% vectorSizeはスケールがよくわからないので実際に動かしながら大きさを調整する
% levelは何画素あたりに表示するかの間隔を指定する
% （例えば[1,1]とするとx座標とy座標1ピクセル毎にベクトルを表示するので大変重い。
%  指定する位置は1pxなので、このままでは重く使えないので、指定する位置を拡大させることにした。
%  この拡大の幅をvectorRangeとする
vectorSize = 5; 
vectorRange = 5;
level = [vectorRange+1 vectorRange+1];

%----- 以下から実行プログラム -----


% GT vectorの読み込み
GTVectorNames = dir(fullfile(workingDir,strcat(gtVectorDir,name),'*.flo'));
GTVectorNames = {GTVectorNames.name}';

% GTに対応するtarget画像の読み込み
targetImageNames = dir(fullfile(workingDir,strcat(trainDir,name),'*.png'));
targetImageNames = {targetImageNames.name}';


% 最初の一枚目の画像を表示してopticalflowをピクセルを設定する
% （クリックしたらreturnキーで決定）
imgpath = strcat(trainDir,name,'/frame_0001.png');
imshow(imgpath);
[x,y] = getpts; % クリックした位置を取得
close;

x_point = round(x(1));
y_point = round(y(1));

to_x_point = x_point+step;
to_y_point = y_point+step;

% オプティカルフローの軌道（正方形表示）の色を白から始める
% （以下のforループで要素数に関してエラーとならないようにダミーを入れているので2行になっている）
color_vector = [255,255,255; 255,255,255];

x_range = [x_point, to_x_point];
y_range = [y_point, to_y_point];


% オプティカルフローのベクトルを画像の上に表示するためのおまじない的なもの
h = figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
hPlot = axes(hViewPanel);

% オプティカルフローのを画像に合成して表示
count = 1;
for ii = 1:length(GTVectorNames)
    
    % 1枚ずつ画像を読み込み
    img = imread(fullfile(workingDir,strcat(trainDir,name),targetImageNames{ii}));
    
    % オプティカルフロー の軌道を正方形で色を変えて表す
    for j = 1:count
        col = zeros(step+1,step+1,3);
        col(:,:,1) = color_vector(j+1,1);
        col(:,:,2) = color_vector(j+1,2);
        col(:,:,3) = color_vector(j+1,3);
        img(y_range(j,1):y_range(j,2), x_range(j,1):x_range(j,2),:) = col;
    end
    count = count + 1;
    % 白色から順に青色に変えていくのでRGBのRGを毎回３ずつ減らしている
    color_vector = [color_vector ; color_vector(end,:) - [3,3,0]];
    
    % GTのベクトルを取得
    F2 = readFlowFile(fullfile(workingDir,strcat(gtVectorDir,name),GTVectorNames{ii}));
    u = F2(:,:,1);
    v = F2(:,:,2);
    nanIdx = isnan(u) | isnan(v); % nanがあるといけないので補完
    u(nanIdx) = 0;
    v(nanIdx) = 0; 
    
    % オプティカルフロー軌道の位置のベクトルを取得
    y_point_range = y_point-1:y_point+1;
    x_point_range = x_point-1:x_point+1;
    x_vector_range = u(y_point_range, x_point_range);
    y_vector_range = v(y_point_range, x_point_range);
    disp(x_vector_range)
    x_vector = mean(x_vector_range, 'all');
    y_vector = mean(y_vector_range, 'all');
    

    % 全てのオプティカルフローベクトルを０にして、軌道位置のものだけにする
    % 軌道位置の表示は本来は1pxだが表示の都合上ピクセルをvectorRange分拡大する
    u(:,:) = 0;
    v(:,:) = 0;
    u(y_point:y_point+vectorRange, x_point:x_point+vectorRange) = x_vector; 
    v(y_point:y_point+vectorRange, x_point:x_point+vectorRange) = y_vector;

    % 軌道を次の位置に更新する
    x_point = floor(x_point + x_vector);
    y_point = floor(y_point + y_vector);
    to_x_point = x_point+step;
    to_y_point = y_point+step;
    
    % 次の位置が画面内に収まる場合（436×1024）は次の位置をそのまま配列に追加
    if (1 <= y_point) && (to_y_point <= 436) && (1 <= x_point) && (to_x_point <= 1024)
        x_range = [x_range; x_point, to_x_point];
        y_range = [y_range; y_point, to_y_point];
        
        flow = opticalFlow(u,v); % オプティカルフローの適用
        
    % 次の位置が画面からはみ出す場合はエラーになるので、画面の端に設定。軌道の連続ではなくなるので、オプティカルフローベクトルは出さないようにする
    else
        if 1 > y_point
            y_point = 1;
            to_y_point = y_point+step;
        end
        if 436 < to_y_point
            to_y_point = 436;
            y_point = to_y_point-step;
        end
        if 1 > x_point
            x_point = 1;
            to_x_point = x_point+step;
        end
        if 1024 < to_x_point
            to_x_point = 1024;
            x_point = to_x_point-step;
        end
        
        x_range = [x_range; x_point, to_x_point];
        y_range = [y_range; y_point, to_y_point];
        u(:,:) = 0;
        v(:,:) = 0;
        flow = opticalFlow(u,v);
    end
    
    % 画面表示
    imshow(img)
    hold on
    plot(flow,'DecimationFactor',level,'ScaleFactor',vectorSize,'Parent',hPlot);
    hold off
    pause(10^-10)
end


