%----- 必要な変数を設定 ------
% matlabの実行ファイルを置く場所
workingDir = '/Users/admin/Desktop/matlab/';
% GTのフォルダをworkingDirの配下に置いてその名前
gtDir = 'gt_image/';
% アニメーションフォルダの親フォルダをworkingDirの配下に置いてその名前
trainDir = 'target_image/';
% 実験したいアニメーションのフォルダ名
name = 'temple_3';
% 画像コマ送りのスピード
waitSec = 0.05;

% 「使い方」
% create_imageというディレクトリをあらかじめ作成して置いてから実行する
% 最初に表示される一枚目の画像でopticalflowを適用する範囲を
% 矩形の左上と右下で設定する（二箇所クリックしたらreturnキーで決定）

%----- 以下から実行プログラム -----

% GT画像の読み込み
imageNames = dir(fullfile(workingDir,strcat(gtDir,name),'*.png'));
imageNames = {imageNames.name}';
% GTに対応するtarget画像の読み込み
targetImageNames = dir(fullfile(workingDir,strcat(trainDir,name),'*.png'));
targetImageNames = {targetImageNames.name}';

% 最初の一枚目の画像を表示してopticalflowを適用する範囲を
% 矩形の左上と右下で設定する（二箇所クリックしたらreturnキーで決定）
imgpath = strcat(trainDir,name,'/frame_0001.png');
imshow(imgpath);
[x,y] = getpts;
close;
x_from = round(x(1));
x_to = round(x(2));
y_from = round(y(1));
y_to = round(y(2));

height = y_from:y_to;
width = x_from:x_to;

% 合成画像生成
for ii = 1:length(imageNames)
    img1 = imread(fullfile(workingDir,strcat(gtDir,name),imageNames{ii}));
    img2 = imread(fullfile(workingDir,strcat(trainDir,name),targetImageNames{ii}));

    
    
    img3 = img2;
    img3(height,width,:) = img1(height,width,:);
    imwrite(img3,sprintf('create_image/image_%02d.png',ii));
end

F2 = readFlowFile('flowfile/frame_0019.flo');
u2 = F2(:,:,1);
v2 = F2(:,:,2);
% -------psychotoolbox---------- 

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
% screenNumber = max(screens);
screenNumber = 0;

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Here we load in an image from file. This one is a image of rabbits that
% is included with PTB

% theImageLocation = [PsychtoolboxRoot 'PsychDemos' filesep...
%     'AlphaImageDemo' filesep 'konijntjes1024x768.jpg'];
theImageLocation = ["create_image/image_01.png"];
theImage = imread(theImageLocation(1));
theImage = imresize(theImage,0.85);
% Get the size of the image
[s1, s2, s3] = size(theImage);
% Here we check if the image is too big to fit on the screen and abort if
% it is. See ImageRescaleDemo to see how to rescale an image.
if s1 > screenYpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end
% 
% % Make the image into a texture
imageTexture = Screen('MakeTexture', window, theImage);

theImageLocation = [
    "create_image/image_01.png","create_image/image_02.png","create_image/image_03.png","create_image/image_04.png", ...
    "create_image/image_05.png","create_image/image_06.png","create_image/image_07.png","create_image/image_08.png", ...
    "create_image/image_09.png","create_image/image_10.png","create_image/image_11.png","create_image/image_12.png", ...
    "create_image/image_13.png","create_image/image_14.png","create_image/image_15.png","create_image/image_16.png", ...
    "create_image/image_17.png","create_image/image_18.png","create_image/image_19.png","create_image/image_20.png", ...
    "create_image/image_21.png","create_image/image_22.png","create_image/image_23.png","create_image/image_24.png", ...
    "create_image/image_25.png","create_image/image_26.png","create_image/image_27.png","create_image/image_28.png", ...
    "create_image/image_29.png","create_image/image_30.png","create_image/image_31.png","create_image/image_32.png", ...
    "create_image/image_33.png","create_image/image_34.png","create_image/image_35.png","create_image/image_36.png", ...
    "create_image/image_37.png","create_image/image_38.png","create_image/image_39.png","create_image/image_40.png", ...
    "create_image/image_41.png","create_image/image_42.png","create_image/image_43.png","create_image/image_44.png", ...
    "create_image/image_45.png","create_image/image_46.png","create_image/image_47.png","create_image/image_48.png", ...
    "create_image/image_49.png","create_image/image_50.png", ...
];

% s = 32;
for c = 1:length(imageNames)
    theImage = imread(theImageLocation(c));
    imageTexture = Screen('MakeTexture', window, theImage);
    Screen('DrawTexture', window, imageTexture, [], [], 0);
    Screen('Flip', window);
    WaitSecs(waitSec);
end
% % Clear the screen
KbWait;
sca;
