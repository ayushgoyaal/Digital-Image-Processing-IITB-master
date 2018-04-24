function recognitionRate = imageRecognition(eigFace,xMean,devTrainCell,testCell,thershold,ks)
    recognitionRate={};
    %Tries to recognise the test image with K eigen Values    
    devTestSet=bsxfun(@minus, testCell{1}, xMean);
    successRate=zeros(1,numel(ks));
    falsePositiveCount=zeros(1,numel(ks));
    falseNegativeCount=zeros(1,numel(ks));
    n=size(devTestSet,2);
    for i=1:numel(ks)        
        [successRate(i),correctRecognition,imageNotInDBPred,falsePositiveCount(i),falseNegativeCount(i),predLabels]=recognise(eigFace,ks(i),thershold(i,:),devTrainCell,{devTestSet,testCell{2}});
        fprintf('K=%d\tRecognition-Rate:%f\t Correctly_Recognised=%d\tFalse_Positive:%d\tFalse_Negative:%d\n',ks(i),successRate(i),correctRecognition,falsePositiveCount(i),falseNegativeCount(i));                      
        falsePositiveCount(i)=falsePositiveCount(i)/n;
        falseNegativeCount(i)=falseNegativeCount(i)/n;
    end
    recognitionRate{1}=ks;
    recognitionRate{2}=successRate;
    recognitionRate{3}=falseNegativeCount;
    recognitionRate{4}=falsePositiveCount;
end


function [successRate,correctRecognition,imageNotInDBPred,falsePositive,falseNegative,predLabels] = recognise(V,k,thershold,devTrainCell,devTestCell)
    %Tries to recognise the test image with K eigen Values
    %taking K largest Eigen vector
    Vk=V(:,1:k);
    VkT=Vk';
    % eigenCoff: kxnumber_of_img 
    aEigenCoff=VkT*devTrainCell{1};
    bEigenCoff=VkT*devTestCell{1};
    n=size(devTestCell{1},2);
    %Label Fetch
    trainLabel=devTrainCell{2};
    testLabel=devTestCell{2};  
    correctRecognition=0;
    imageNotInDBPred=0;
    falsePositive=0;
    falseNegative=0;
    predLabels=zeros(n,1);   
    for i=1:n
        bCoff_i=bEigenCoff(:,i);
        % j= || aj-b||2
        alphaMinusBeta=bsxfun(@minus, aEigenCoff, bCoff_i);
        alphaMinusBetaSq=alphaMinusBeta.^2;
        alphaMinusBetaNorm=sum(alphaMinusBetaSq);
        % Recognisation: j= min || aj-b||2  for j in the train set       
        [error,index]=min(alphaMinusBetaNorm);        
        %fprintf('testImg_%d : %d error:%f\n',i,index,sqrt(error));
        error=sqrt(error);            
        predictedLabel=trainLabel(index);
        trueLabel=testLabel(i);
        th=thershold(predictedLabel);
        if(predictedLabel==trueLabel && error > th )
            % Image is in database but wrong prediction    
            falseNegative=falseNegative+1;
            predLabels(i)=-1;
        end
        if(predictedLabel~=trueLabel && error < th)
            % Image is in NOT database and also predicted wrongly
             falsePositive=falsePositive+1;     
             predLabels(i)=-2;
        end
        if(predictedLabel==trueLabel && error < th)
            %Image in database and also predicted right
            correctRecognition=correctRecognition+1;   
            predLabels(i)=trueLabel;
        end
        if(predictedLabel~=trueLabel && error > th)
            % Image is in NOT database and also predicted right
             correctRecognition=correctRecognition+1;              
             imageNotInDBPred=imageNotInDBPred+1;
             predLabels(i)=-3;
        end
    end    
    successRate=correctRecognition/n;    
end
