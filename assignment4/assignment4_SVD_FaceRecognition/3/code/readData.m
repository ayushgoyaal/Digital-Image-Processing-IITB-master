% Reads the images from the Database and returns the trainImage dataset and
% test image data set.
function [trainImgCell,valImgCell,testImgCell]=readData(dirpath,dimension,totalPerson,numOfPerson,trainSize,valSize,testSize)
    row=dimension(1);col=dimension(2);
    % Train  martix Init
    % Total TrainImage: (perPersonTrain*numOfPerson) 
    noOfTrainImage=(numOfPerson*trainSize);   
    trainImgMatrix=zeros(row*col,noOfTrainImage);
    trainImgLabel=zeros(noOfTrainImage,1);
    
    % Validate Image
    % Total TrainImage: (perPersonVal*numOfPerson) 
    noOfValImage=(numOfPerson*valSize);   
    valImgMatrix=zeros(row*col,noOfValImage);
    valImgLabel=zeros(noOfValImage,1);
    
    % Test  martix Init
    % Total TestImage: (perPersonTest*numOfPerson) + (10*totalPerson)
    % i.e (4*32) + (10*8) 
    noOfTestImage=(numOfPerson*testSize) + (10*(totalPerson-numOfPerson));
    testImgMatrix=zeros(row*col,noOfTestImage);   
    testImgLabel=zeros(noOfTestImage,1);
    
    imgFolderPerPerson = dir(dirpath);
    imgFolderPerPerson=natsortfiles({imgFolderPerPerson.name}); 
    personCount=0;            
    
    for i= 1:numel(imgFolderPerPerson);  
            folderName=imgFolderPerPerson(i);folderName=folderName{1};
            if ( strcmp( folderName,'.') || strcmp(folderName,'..') || strcmp(folderName,'README'))
                continue;
            end
            if personCount>= totalPerson 
                break;
            end
            
            
            imgDirPerPerson=strcat(dirpath,'/',folderName);
            imgFilesPerPerson = dir(imgDirPerPerson);            
            perPersonCount=1;
            %fprintf('-----------[%s]-------------\n',folderName);
            for j = 1:numel(imgFilesPerPerson)
                    %fileName=imgFilesPerPerson(j);fileName=fileName{1};
                    fileName=imgFilesPerPerson(j).name;
                    if ( strcmp(fileName,'.') || strcmp(fileName,'..'))
                        continue;
                    end 
                    fullFilePath=strcat(imgDirPerPerson,'/',fileName);
                    %fprintf('%s:\n',fullFilePath);
                    img = imread(fullFilePath);
                    [irow,icol] = size(img);
                    vector = reshape(img,irow*icol,1);
                    if personCount < numOfPerson 
                            if perPersonCount <= trainSize
                                k=(personCount*trainSize)+perPersonCount;
                                trainImgMatrix(:,k) = vector;
                                trainImgLabel(k)=personCount+1;
                            elseif perPersonCount <= trainSize+valSize;
                                k=(personCount*valSize)+perPersonCount-trainSize;
                                valImgMatrix(:,k) = vector;
                                valImgLabel(k)=personCount+1;                            
                            else                               
                                k=(personCount*testSize)+perPersonCount-trainSize-valSize;
                                testImgMatrix(:,k) = vector;
                                testImgLabel(k)=personCount+1;
                            end
                    else
                            k=(numOfPerson*testSize)+((personCount-numOfPerson)*10)+perPersonCount;
                            testImgMatrix(:,k) = vector;
                            testImgLabel(k)=personCount+1;
                    end                                
                    perPersonCount=perPersonCount+1;
            end
            personCount=personCount+1;
    end 
    trainImgCell={trainImgMatrix,trainImgLabel};
    valImgCell={valImgMatrix,valImgLabel};    
    testImgCell={testImgMatrix,testImgLabel};
    
end

            