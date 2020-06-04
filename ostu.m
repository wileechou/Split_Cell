function [T0] = ostu(J1)
[m,n]=size(J1);
g0=0;
T0=0;
Jmin=min(J1(:));
Jmax=max(J1(:));
for T=Jmin:1/255:Jmax
    w0=sum(J1(:)<T)/(m*n);
    w1=sum(J1(:)>T)/(m*n); 
    u0=mean(J1(J1>T));
    u1=mean(J1(J1<T));
    g=w0*w1*(u0-u1)^2;
    if g>g0
        g0=g;
        T0=T;
    end   
end 
end

