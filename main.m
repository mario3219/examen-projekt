%INFO OM DENNA FIL

%Här finns massa tillämpningar av koden från ALLfuncs.m och RHDfuncs.m som
%nyttjades ofta, men som jag bedömde inte var tillräckligt invecklade för
%att behöva göras som metoder.

%% läser in olika filer

%Jag tyckte att det var omständigt att skriva in path i metoderna hela
%tiden, så jag gjorde detta till en egen sektion

clc,clear
file = "D:\Mina Actual Dokument\Skola\EEML05\data files\hot vs cold experiments\input\25_1"
background = "C:\Users\Jonathan Olsson\Documents\Kurser\EEML05\experiments\hot vs cold experiments\output\04-08\52_1\background_1"

%% kod snutt för att snabbt plotta intensitetsprofilen för en viss datapunkt
ALLfuncs.plotIntensity(ALLfuncs.calcIntensity(file,""),file,"");

%%
ALLfuncs.plotIntensity(ALLfuncs.calcNormalizedIntensity(file),file,"");

%% plotta profilen för endast EN tif fil

% Under rhodamine labbarna så behövde jag konstant kolla ifall flödet hade
% stabiliserats sig, så jag använde denna metod väldigt ofta. Skrev in det
% här i ett eget avsnitt så jag snabbt kunde köra den

ALLfuncs.plotIntensityOneTIF(file)

%% Skriver ut alla datapunkter som gjorts hitills

% Under rhodamine labbarna så ville jag snabbt få en översikt på vilka
% punkter jag skaffat hitills (input och output) så jag gjorde en egen
% sektion för att kolla det

clc
inputdata = "D:\Mina Actual Dokument\Skola\EEML05\data files\hot vs cold experiments\input"
outputdata = "D:\Mina Actual Dokument\Skola\EEML05\data files\hot vs cold experiments\input"
data = RHDfuncs.importData(inputdata,outputdata)

%% Itererar igenom alla punkter i 'data' från ovan och kör plotIntensity

% Denna kod nyttjades för att se snabbt ifall intensiteten varierar rimligt
% mycket mellan temperatur ändringarna

%OBS: Jag bestämde för att ta bakgrundsbilder varje gång jag tog en
%mätning. Jag lagrade dessa bakgrunder i samma fil som själva mätningen.
%tex inne i "\hot vs cold experiments\input\21_1" hittar man 'background_1'

for i = 1:1:height(data)
        %bakgrunden hittas INNE i filen som values beräknas ifrån
        background = data(i,1) + "\background_1";
        values = ALLfuncs.calcIntensity(data(i,2),background);
        %tar bort första 5 värdena (det blev alltid spikar)
        values(1:5) = [];
        ALLfuncs.plotIntensity(values,data(i,1),background);
end

%% Plottar Intensiteten som funktion av temperatur

% Denna kod nytjades under rhodamine labbarna för att se om det fanns en
% linjäritet mellan intensitet och vilken temperatur rhodaminet hade.

%koden nyttjar tabellen 'data' som beräknas i avsnittet ovanför

%OBS: Jag bestämde för att ta bakgrundsbilder varje gång jag tog en
%mätning. Jag lagrade dessa bakgrunder i samma fil som själva mätningen.
%tex inne i "\hot vs cold experiments\input\21_1" hittar man 'background_1'

x = zeros(height(data),1);
y = zeros(height(data),1);
for i = 1:1:height(data)
    values = ALLfuncs.calcIntensity(data(i,2),"");
    %tar bort första 3 värdena (det blev alltid spikar)
    values(1:3) = [];
    x(i) = nanmean(values);
    y(i) = double(data(i,3));
end
figure
plot(y,x),ylabel("Intensity"),xlabel("Temperature(C)")

%%
clc

data = RHDfuncs.importData(file,file);
x = zeros(height(data),2);

for i = 1:1:height(data)
    %cd(data(i,2))
    temp = data(i,2);
    name = split(temp,"\");
    temp = name(length(name));
    name = split(temp,"delta ");
    name = name(length(name));

    values = ALLfuncs.calcIntensity(data(i,2) + "\rhd_1","");
    values(1:3) = [];
    values(height(values)-1:height(values)) = [];
    x(i,1) = name;
    x(i,2) = string(max(values)-min(values));
    figure,plot(values),title(name)

%     figure
%     plot(values)
%     title(name)
%     x(i) = nanstd(values);
end

%%
clc

file = "C:\Users\Jonathan Olsson\Documents\Kurser\EEML05\experiments\parameter analysis\voltage";
data = RHDfuncs.importData(file,file);
x = zeros(height(data),5);
y = string(height(data));
for i = 1:1:height(data)
    values = ALLfuncs.calcIntensity(data(i,1),"");
    values(1:3) = [];
    values(length(values)-10:length(values)) = [];
    %ALLfuncs.plotIntensity(values,data(i,1),"")
    x(i,1) = string(min(values));
    x(i,2) = string(max(values));
    x(i,3) = string(max(values)-min(values));
    x(i,4) = string(std(values));
    y(i,1) = data(i,1);
end

x(height(x),:) = [];
x(height(x)+1,:) = x(4,:);
x(4,:) = [];

y(height(y),:) = [];
y(height(y)+1,:) = y(4,:);
y(4,:) = [];

for i = 1:1:width(x)
    figure
    plot(x(:,i))
    title(i)
end

%%

Q1 = v1*A
Q2 = v2*A

