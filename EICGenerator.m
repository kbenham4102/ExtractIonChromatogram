% Program to Generate EIC's from .ascii data exported from compass Xport
% Must export data with mass precision 4. Xport still outputs the
% whole spectral time series despite selecting TIC or EIC.
% Masses at each time are recorded in odd columns, intensity of listed mass
% at those times are in the adjacent cell to the right of the mass.
% This program takes that data and organizes it so that an EIC from an
% integrated peak can be obtained.
% Specifically meant to import MS data for spectra taken every second for
% 60 seconds. 
% Will cut data off or produce error if file is not of row dimension 60
clear
prompt = ('Input file to be imported as cell array      ');
EIC = importfileEICprof(input(prompt,'s'),1,60);
%------------- Set peak width to be integrated via input -----------------
prompt = ('Indicate minimum mass for EIC   '); 
mz1 = input(prompt);
prompt = ('Indicate maximum mass for EIC   ');
mz2 = input(prompt);
%-------------------------------------------------------------------------
szy = size(EIC);
elem = 0;
% This search goes through each row (i.e. for constant time) and returns 
% the masses with their intensity at that time t. 
for i=1:szy(1)
    for j=1:2:szy(2)
       if EIC(i,j)>mz1 && EIC(i,j)<mz2;
           elem = elem+1;
           x(elem,:) = [EIC(i,j) EIC(i,j+1) i j];
       end
    end
end

%figure
%scatter3(x(:,3),x(:,2),x(:,1))
k = round((elem/60));
n = 0;
for i = 1:60
    B(i,:) = [ i trapz(x((1+n):(k+n),1),x((1+n):(k+n),2))];
    n = n+k; 
end
 
prompt = ('Plot data? (Y/N) ');
plt = input(prompt, 's');
if plt == 'Y'
    figure(1)
    plot(B(:,1),B(:,2),'r')
    xlabel('t')
    ylabel('arb')
end
 
IntEIC = trapz(B(:,1),B(:,2));
prompt = ('Save EIC data? Y=1/N=2   ');
s = input(prompt);
if s==1
    prompt = ('Enter filename    ');
    filename = input(prompt,'s');
    fileID = fopen(filename,'w');
    fprintf(fileID,'%8s %8s\r\n','time(s)','arb');
    fprintf(fileID,'%8.6f %8.2f\r\n',B');
    fclose(fileID);
end
        