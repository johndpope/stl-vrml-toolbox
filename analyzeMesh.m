function [P2,K2]=analyzeMesh(P,K,rplimit)
%P=1000*P;
figure()
subplot(1,2,1)

eztrisurf(K,P);
title('Original model');
axis equal

N=size(P,1);
V=zeros(N,1);
for k=1:size(P,1)
    V(k)=getSlice(k,P,K);
end

[vs,ix]=sort(V);

lower=1;
upper=N;
numremove=floor(N/2);
V1=meshVolume(P,K);
rp=1;
while (upper-lower)>2
    if rp<rplimit
        upper=numremove
    else
        lower=numremove
    end
    numremove=floor((lower+upper)/2)
    
    P2=P(ix(numremove:end),:);
    K2=convhull(P2(:,1),P2(:,2),P2(:,3));
    V2=meshVolume(P2,K2);
    rp=V2/V1;
    
end


subplot(1,2,2)
eztrisurf(K2,P2)
title(sprintf('Reduced # points = %d, Volume ratio %f',numremove,rp));
axis equal

%P2=P2/1000
end

function A=triangleAreas(P,K)
A=zeros(size(K,1),1);
for r=1:size(K,1)
    A(r)=triangleArea3d(P(K(r,1),:),P(K(r,2),:),P(K(r,3),:));
end
end

function V=getSlice(ind,P,K)

[r,c]=find(K==ind);
kslice=K(r,:);
pslice=P(unique(kslice(:)),:);
try
    K2=convhull(pslice);
    V=meshVolume(pslice,K2);
catch
    V=0;
end

end


