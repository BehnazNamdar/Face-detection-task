% Face detection task

% 500 ms fixation
% 300 ms stimulus
% 500 ms delay
% Response collection
% Plot Psychometric function



% Clear the workspace
close all;
clearvars;
sca; 



Screen('Preference', 'SkipSyncTests', 1);
[width, height]=Screen('WindowSize',max(Screen('Screens')));
rect = [0 0 width height];

screenNumber = max(Screen('Screens'));
[wPtr, windowRect] = Screen('OpenWindow', screenNumber, 128, rect );


% -------------------------
% set fixation point parameters
% -------------------------

[xCenter, yCenter] = RectCenter(windowRect);
crossColor=255;
crossWidth=3;
crossLengh = 20;
crossLines=[-crossLengh , 0 ; crossLengh , 0 ; 0 , -crossLengh ; 0 , crossLengh];
crossLines=crossLines';



% ---------------------
% Keyboard information
% ---------------------

% Define the keyboard keys that are listened for. 
% We will be using the 1  for  face images
% and  2 key for  not face images




% -------------------------
% set stimulus parameters
% -------------------------

% number of blocks in experiment
block = 5; 

% set face images:
% -----------------
% read base images from face folder and put the value in ffiles 
pathf = [cd , '/images/face/'];
fFiles = dir([pathf ,'*.tif']);

fdirBase = fFiles(1).folder;  % folder containing required face files


% make a  new dir for face  images
mkdir images newFimages;

newFdir = [cd , '/images/newFimages'] ;

% make a loop for reading face files
for i = 1 : length(fFiles)
    
    imageFBase = strcat(fdirBase,'/',fFiles(i).name); 
    imageF = imread(imageFBase);
    imagerszF = imresize(imageF, [300 300]);
    
    % make a loop to add noise to images 
    % and save them in a new folder
    
    for j = 1 : 5 
        
        m = ( 2 * (j-1) ) / 10 ;
        imFnoisy = imnoise(imagerszF, 'Gaussian' , m );
        imgFName = [newFdir,'/Image_',num2str(i),'_', num2str(j) ,'.jpg'] ;
        imwrite(imFnoisy , imgFName );       
        
    end     
    
end



% set nface images:
% -----------------
pathn = [cd , '/images/nface/'];
nFiles = dir([pathn ,'*.tif']);

% read base images from nface folder and put the value in nfiles 

ndirBase = nFiles(1).folder;  % folder containing required nface files


% make a  new dir for  nface images
mkdir images newNimages
newNdir = [cd, '/images/newNimages'] ;



% make a loop for reading nface files


i = 0;
j = 0;

for i = 1 : length(nFiles)
    
    imageNBase = strcat(ndirBase,'/',nFiles(i).name); 
    imageN = imread(imageNBase);
    imagerszN = imresize(imageN, [300 300]);
    
    % make a loop to add noise to images 
    % and save them in a new folder
    
    for j = 1 : 5 
        
        m = ( 2 * j ) / 10 ;
        imNnoisy = imnoise(imagerszN , 'Gaussian' , m );
        imgNName = [newNdir,'/Image_',num2str(i),'_', num2str(j) ,'.jpg'] ;
        imwrite(imNnoisy , imgNName ); 
    end
    
end

i = 0;
j = 0;

% enter new dir of new files in a variable 
% for face images 
newFFiles =  dir([newFdir, '/*.jpg']) ;
% for nface images
newNFiles = dir([newNdir, '/*.jpg']);
% concat all the files
newFiles = cat(1,newFFiles,newNFiles);


% make a structure variable containing trials per block * number of blocks
BnewFiles = repmat(newFiles, block , 1);

% make a zero double variable to insert block numbers of ntrials
blocklist = zeros(block *  numel(newFiles) , 1) ;

% fill blocklist variable 
for j = 1 : block 
    v = repmat(j , numel(newFiles) , 1 );
    blocklist( 1 + numel(newFiles)*(j-1) : numel(newFiles)*j ) = v;
end
j =0;
% convert blocklist vector from num to cell type 
c = num2cell(blocklist);
% add and fill nblock field of BnewFiles structure variable 
[BnewFiles.nblock] = c{:};



% shuffle files to show them randomly
newFilesShfl = Shuffle(BnewFiles);

% sort newFilesShfl by nblock
z1 = struct2table(newFilesShfl);
z2 = sortrows(z1, 'nblock');
BnewFilesShfl = table2struct(z2);



% save correct responses in response matrix
for i = 1: length(BnewFilesShfl) 
    response(i).ntrial = i;  % write trail number in response matrix
    response(i).nblock = BnewFilesShfl(i).nblock;  % write block number in response matrix
    
    % write condition number in response matrix
    response(i).condition = str2num(BnewFilesShfl(i).name(9));
    
    
    if BnewFilesShfl(i).folder == newFdir ;
        response(i).corAns = 1;
    else
        response(i).corAns = 2;
    end    
    
end







%% instrusction

Screen('TextFont', wPtr, 'Times'); % set the font for the screen to Arial
Screen('TextSize', wPtr, 24); % set the font size for the screen to 24
text = 'You will see numbers of images containing either face or non face.  \n You should press 1 when you see face and \n press 2 when you see non face images.\n Press any key to start when you are ready';
       
DrawFormattedText(wPtr, text ,'center', 'center', 255);

Screen('Flip', wPtr);

KbWait;



%% experimental loop


for k = 1 :  length(BnewFilesShfl)
    
    
    % Draw fixation point

    Screen('DrawLines',wPtr,crossLines,crossWidth,crossColor,[xCenter,yCenter]);
    Screen('Flip',wPtr);
    WaitSecs(0.5);
    
    
    % show stimulus 

    stim = imread(strcat(BnewFilesShfl(k).folder,'/',BnewFilesShfl(k).name));
    stimM = Screen('MakeTexture', wPtr , stim); 
    Screen('DrawTexture',wPtr,stimM);
    Screen('Flip',wPtr);
    WaitSecs(0.3);
    
    
    % delay 
     
    Screen('DrawLines',wPtr,crossLines,crossWidth,crossColor,[xCenter,yCenter]);
    Screen('Flip',wPtr);
    WaitSecs(0.5);
    
    
    
    RestrictKeysForKbCheck([KbName('1!'), KbName('2@')]);
    
    keyIsDown = 0;
    tStart = GetSecs;
    while ~keyIsDown 
        [keyIsDown,secs, keyCode] = KbCheck(-1);
    end
    
    a = KbName(find(keyCode));
    pressedKey = char(extract(a,1));
    

    if pressedKey == '1' 
       resp = 1 ;   
    elseif pressedKey == '2' 
       resp = 2 ; 
    end
       
    % calculate reaction time 
    rt = secs - tStart;
    
    % save reaction time in reresponse variable for each image
    response(k).rt = rt;
    response(k).respns = resp;

end

k = 0;
for k= 1:   length(BnewFilesShfl)
   if response(k).corAns == response(k).respns
      response(k).accuracy = 1 ;
   else
      response(k).accuracy = 0 ;
   
   end
    
end

save Face_Detection_task.mat response;
sca

%% plot 

clear all;
load Face_detection_task.mat; 


% conclusionMatrix = zeros(5,150);
% 
% for jj = 1: length([response.ntrial])
%     conclusionMatrix(1,jj) = response(jj).ntrial;  % 1: trial num
%     switch  response(jj).corAns
%         case 1
%             conclusionMatrix(2, jj) = 1; % 2 1= face , 2= non-face
%             if response(jj).respns == conclusionMatrix(2, jj) 
%                 conclusionMatrix(5, jj) = 1; % 5 is accuracy
%             end
%         case 2
%             conclusionMatrix(2, jj) = 2;
%             conclusionMatrix(5, jj) = 0;
%     end
%     
%     switch response(jj).condition
%         case 1
%             conclusionMatrix(3, jj) = 1;  % 3 condition
%             conclusionMatrix(4, jj) = response(jj).rt ;  % 4 rt
%             
%         case 2
%             conclusionMatrix(3, jj) = 2;
%             conclusionMatrix(4, jj) = response(jj).rt ;
%         case 3
%             conclusionMatrix(3, jj) = 3;
%             conclusionMatrix(4, jj) = response(jj).rt ;
%         case 4
%             conclusionMatrix(3, jj) = 4;
%             conclusionMatrix(4, jj) = response(jj).rt ;
%         case 5
%             conclusionMatrix(3, jj) = 5;
%             conclusionMatrix(4, jj) = response(jj).rt ;
% 
%     end
% end
% 

% extract conditions
conditions = unique([response.condition]);
a = zeros(6,5);
b = zeros(6,5);
block = 5;
for ii = 1: length([response.ntrial])
    switch response(ii).corAns
        case 1 
            switch response(ii).condition
                case 5
                    a(1,1) = 5;
                    a(2,1) = length([response.ntrial]) / (2 * length(conditions)) ;
                    a(3,1) = a(3,1) + response(ii).accuracy ; % accuracy
                    a(4,1) = a(4,1) + response(ii).rt; % rt
                    a(5,1) = a(3,1) / a(2,1); % accuracy
                    a(6,1) = a(4,1) / a(2,1); % rt
                case 4
                    a(1,2) = 4;
                    a(2,2) = length([response.ntrial]) / (2 * length(conditions));
                    a(3,2) = a(3,2) + response(ii).accuracy;
                    a(4,2) = a(4,2) + response(ii).rt;
                    a(5,2) = a(3,2) / a(2,2);
                    a(6,2) = a(4,2) / a(2,2);
                case 3
                    a(1,3) = 3;
                    a(2,3) = length([response.ntrial]) / (2 * length(conditions));
                    a(3,3) = a(3,3) + response(ii).accuracy;
                    a(4,3) = a(4,3) + response(ii).rt;
                    a(5,3) = a(3,3) / a(2,3);
                    a(6,3) = a(4,3) / a(2,3);
                case 2
                    a(1,4) = 2;
                    a(2,4) = length([response.ntrial]) / (2 * length(conditions));
                    a(3,4) = a(3,4) + response(ii).accuracy;
                    a(4,4) = a(4,4) + response(ii).rt;
                    a(5,4) = a(3,4) / a(2,4);
                    a(6,4) = a(4,4) / a(2,4);
                case 1
                    a(1,5) = 1;
                    a(2,5) = length([response.ntrial]) / (2 * length(conditions));
                    a(3,5) = a(3,5) + response(ii).accuracy;
                    a(4,5) = a(4,5) + response(ii).rt;
                    a(5,5) = a(3,5) / a(2,5);
                    a(6,5) = a(4,5) / a(2,5);
            end
        case 2 
            switch response(ii).condition
                case 1
                    b(1,1) = 1;
                    b(2,1) = length([response.ntrial]) / (2 * length(conditions)) ;
                    b(3,1) = b(3,1) + response(ii).accuracy; % accuracy
                    b(4,1) = b(4,1) + response(ii).rt; % rt
                    b(5,1) = b(3,1) / b(2,1); % accuracy
                    b(6,1) = b(4,1) / b(2,1); % rt
                case 2
                    b(1,2) = 2;
                    b(2,2) = length([response.ntrial]) / (2 * length(conditions));
                    b(3,2) = b(3,2) + response(ii).accuracy;
                    b(4,2) = b(4,2) + response(ii).rt;
                    b(5,2) = b(3,2) / b(2,2);
                    b(6,2) = b(4,2) / b(2,2);
                case 3
                    b(1,3) = 3;
                    b(2,3) = length([response.ntrial]) / (2 * length(conditions));
                    b(3,3) = b(3,3) + response(ii).accuracy;
                    b(4,3) = b(4,3) + response(ii).rt;
                    b(5,3) = b(3,3) / b(2,3);
                    b(6,3) = b(4,3) / b(2,3);
                case 4
                    b(1,4) = 4;
                    b(2,4) = length([response.ntrial]) / (2 * length(conditions));
                    b(3,4) = b(3,4) + response(ii).accuracy;
                    b(4,4) = b(4,4) + response(ii).rt;
                    b(5,4) = b(3,4) / b(2,4);
                    b(6,4) = b(4,4) / b(2,4);
                case 5
                    b(1,5) = 5;
                    b(2,5) = length([response.ntrial]) / (2 * length(conditions));
                    b(3,5) = b(3,5) + response(ii).accuracy;
                    b(4,5) = b(4,5) + response(ii).rt;
                    b(5,5) = b(3,5) / b(2,5);
                    b(6,5) = b(4,5) / b(2,5);
            
            end
    end
end


ba = cat(2 , b ,a);

save b.mat;
save a.mat;
save ba.mat ;


figure

subplot(121)
hold on
plot( ba(5,:), 'g');
title('Images performance');
xlabel('Visual Signal');
ylabel('Performance');


subplot(122)

hold on
plot( ba(6,:), 'b');
title('Images RT');
xlabel('Visual Signal');
ylabel('Reaction Time');



