classdef ALLfuncs
        methods(Static)
            
            function values = calcIntensity(file,backgroundfile)

                %Den här koden beräknar intensitetsprofilen för en specifik
                %fil

                %Ingångsparametrar:
                %file: path till den filen som tif filen befinner sig i
                %tex "D:\Mina Actual Dokument\Skola\EEML05\data files\2mhz temp experiments\frequencies\1.2MHz_1"
                %och inne i denna fil finns då själva tif filen
                
                %backgroundfile: path till bakgrundsfilen som bakgrunds tif
                %bilderna befinner sig i
                %om man inte vill använda en bakgrundsfil, ange bara "" som
                %parameter (tom string)

                %lagrar path som ALLfuncs.m befinner sig i
                oldFolder = cd;
                
                %hämtar namnet på filen du läser in och skriver ut den i
                %konsolen
                str = file;
                str = split(file,"\");
                fprintf("Registered data: " + str(length(str)) + "\n")
                
                %bearbetar bakgrundsfilen, om den angavs som parameter
                foundbackground = 0;
                backgroundvalues = 0;
                if backgroundfile ~= ""
                    foundbackground = 1;
                    
                    %skriver ut vilken bakgrundsfil i konsolen som laddas
                    strb = backgroundfile;
                    strb = split(file,"\");
                    fprintf("Registered background data: " + strb(length(strb)) + "\n")
                    
                    %navigerar till den filen
                    cd(backgroundfile)

                    %läser in tif filen
                    d = dir('*.tif');
                    [~,idx] = max([d.datenum]);
                    backgroundimages = d(idx).name;

                    % sparar info om tif filen
                    info = imfinfo(backgroundimages);
                    X = imread(backgroundimages,1);
                    backgroundvalues = zeros(height(X),1);
                    
                    fprintf("Calculating background values..." + "\n")

                    %beräknar värden från bakgrundsfilen, som nyttjas
                    %senare

                    %HUR VÄRDENA BERÄKNAS:
                    %koden itererar igenom varje bild som finns i tif
                    %filen (for loop) och anger alla intensiteter som är
                    %under 200 som null (kolsvart) och beräknar därefter
                    %medelvärdet för varje rad i bilden
                    for i = 1:1:height(info)
                        background = double(imread(backgroundimages,i));
                        background(background < 200) = NaN;
                        backgroundvalues = (backgroundvalues + nanmean(background,2));
                    end
                    backgroundvalues = backgroundvalues/height(info);
                end

                %navigerar nu till själva data filen som
                %intensitetsprofilen ska beräknas ifrån
                cd(oldFolder)
                cd(file);

                %hittar tif filen
                d = dir('*.tif');
                [~,idx] = max([d.datenum]);
                images = d(idx).name;

                % sparar info om tif filen
                info = imfinfo(images);
                X = imread(images,1);
                values = zeros(height(X),1);

                % loopar igenom alla bilder i tif-filen
                for i = 1:1:height(info)

                    %konverterar rgb matrisen till double. Här subtraheras
                    %bakgrunden också
                    image = double(imread(images,i))-backgroundvalues;
                    
                    %sätter alla pixlar vars värde är under 200 till null
                    image(image < 200) = NaN;
                    
                    %summerar medelvärden för varje kolumn
                    values = (values + nanmean(image,2));
                end

                %dividera med antalet bilder som nyttjades, så intensiteten
                %är ett medelvärde för alla bilder
                values = values/height(info);

                %tar bort alla null värden i vektorn
                values(values == NaN) = [];
                fprintf("Values calculated!" + "\n")

                %återvänder till mappen där ALLfuncs.m befinner sig i
                cd(oldFolder);

            end
            function values = calcNormalizedIntensity(file)
                
                %den här koden beräknar normaliserad intensitetsprofil för
                %en önskad data fil
                values = ALLfuncs.calcIntensity(file,"");
                values = values/double(max(values,[],"all"));

            end
            function plotIntensity(values, file, backgroundfile)
                
                %den här koden plottar intensitetsprofilen

                %Ingångsparametrar:
                %values: de värden som beräknas från calcIntensity eller
                %calcNormalizedIntensity

                %file: path till den fil som calcIntensity eller
                %calcNormalizedIntensity beräknades från
                %tex "D:\Mina Actual Dokument\Skola\EEML05\data files\2mhz temp experiments\frequencies\1.2MHz_1"
                %values måste beräknas från samma file, annars så kommer
                %average bilden som beräknas inte representera samma graf

                %backgroundfile: path till bakgrundsfilen som nyttjades när values
                %beräknades. Måste tillhöra samma instans som när values
                %beräknades (samma anledning som ovan)
                %om ingen bakgrundsfil nyttjades nån gång, används bara ""
                %som ingångsparameter (tom string)

                fprintf("Calculating background..." + "\n")

                %lagrar path som allFuncs.m är lagrad i
                oldFolder = cd;

                %beräknar bakgrundsvärden (nyttjas sen för average bilden)
                if backgroundfile ~= ""
                    cd(backgroundfile)
                    d = dir('*.tif');
                    [~,idx] = max([d.datenum]);
                    backgroundimages = d(idx).name;
    
                    % sparar info om tif filen
                    info = imfinfo(backgroundimages);
                    Y = imread(backgroundimages,1);
                    background = zeros(height(Y),width(Y));
                            
                    for i = 1:1:height(info)
                        backgroundimage = double(imread(backgroundimages,i));
                        backgroundimage(backgroundimage < 200) = 0;
                        background = background + backgroundimage;
                    end
                    background = background/height(info);
                else
                    background = 0;
                end
                cd(oldFolder)
                
                fprintf("Calculating final image..." + "\n")

                cd(file);
                d = dir('*.tif');
                [~,idx] = max([d.datenum]);
                images = d(idx).name;

                info = imfinfo(images);
                [X,cmap] = imread(images,1);

                %skapar noll matris för medelvärdade bilden
                averaged_image = zeros(height(X),width(X));

                %skapar medelvärdes bildade bilden
                for i = 1:1:height(info)
                    image = double(imread(images,i));
                    image(image < 200) = NaN;
                    averaged_image = averaged_image + image - background;
                end
                averaged_image = averaged_image/height(info);

                %beräknar peakestimate
                peakestimate = zeros(height(values),1);
                for i = 1:1:height(values)
                    if values(i) >= 0.5
                        peakestimate(i) = 1;
                    end
                end
                peakestimate = sum(peakestimate,"all");
                
                %konverterar rgb matrisen tillbaka till uint16, måste göras
                %för att kunna 'se' bilden
                averaged_image = uint16(averaged_image);
                
                %plottar allt
                figure;
                subplot(1,3,1)
                imshow(averaged_image,cmap)
                subplot(1,3,2)
                plot(values)
                str = split(file,"\");
                title(string(str(height(str))))
                ylabel("Intensity"),xlabel("Channel width")
                hold on

                %skapar textrutan. Görs genom att skapa en graf, men gör
                %axlarna osynliga
                subplot(1,3,3)
                xlim([0 10])
                ylim([0 10])
                h = gca;
                h.XAxis.Visible = 'off';
                h.YAxis.Visible = 'off';

                txt = ["Standardavvikelse: " + std(values) ,"Medelvärde: " + nanmean(values), "Peakestimate: " + peakestimate];
                text(-2,8,txt)

                %återvänder till executable path
                cd(oldFolder)
            
            end
            function plotIntensityOneTIF(file)

                %plottar medelvärdes intensiteten som funktion av bilderna
                %i tif filen.

                %ingångsparametrar:
                %file: path till den fil du vill plotta
                %tex "D:\Mina Actual Dokument\Skola\EEML05\data files\2mhz temp experiments\frequencies\1.2MHz_1"

                oldFolder = cd;
                
                str = file;
                str = split(file,"\");
                str = str(length(str));
                fprintf("Registered data: " + str(length(str)) + "\n")
                
                cd(file);

                d = dir('*.tif');
                [~,idx] = max([d.datenum]);
                images = d(idx).name;

                % sparar info om tif filen
                info = imfinfo(images);
                values = zeros(height(info),1);

                % loopar igenom alla bilder i tif-filen
                for i = 1:1:height(info)
                    
                    %konverterar rgb matrisen till double
                    image = double(imread(images,i));
                    
                    %summerar medelvärden för varje kolumn
                    values(i) = mean(image,"all");
                end
                fprintf("Values calculated!" + "\n")
                figure
                plot(values),ylabel("Intensity"),xlabel("Time"),title(str);

                %återvänder till executable path
                cd(oldFolder);

            end
            function formatData()

                %den här koden kollar efter filer i unformatted data mappen
                %och byter temp filernas namn till vad vi hade för
                %variabler, därefter flyttar datan till en lämplig mapp

                %OBS: en mapp 'unformatted data' måste finnas i samma plats
                %som ALLfuncs.m körs i

                %OBS: denna kod skulle nyttjas vid parameter analysen, men
                %eftersom vi kanske skippar det så är denna kod kanske
                %onödig
                
                %lagrar path från executable till data path
                oldFolder = cd;

                cd("unformatted data")

                % läser in alla filer
                d = dir('*temp*');

                %kollar om det finns unformatted data
                if length(d) == 0
                    fprintf("No unformatted data available" + "\n")
                    cd(oldFolder)
                    return
                end

                % sorterar enligt datum och tid
                [~,idx] = max([d.datenum]);
                
                %skriver vilken fil som blev inläst
                fprintf("Inlästfil: " + d(idx).name + "\n")

                %låter användaren skriva in vilka parametrar som användes
                %under försöket
                var1 = input("var1: ");
                var2 = input("var2: ");
                var3 = input("var3: ");
                vars = ["var1_" + var1 "var2_" + var2 "var3_" + var3];

                %tar den senaste uppdaterade temp filen och byter namn till
                %parametrar infon
                newfile = "var1" + var1 + "_var2" + var2 + "_var3" + var3 + ".data";
                
                 %hittar all tillgänglig data som skapats hitills
                paths = ALLfuncs.findDataPaths;

                %itererar igenom varje fil i 'unformatted data' mappen
                %ifall det redan finns en fil som har namnet som angavs av
                %användaren, annars lägger till _1 och uppåt ifall den
                %finns
                i = 1;
                k = 1;
                while i <= height(paths)
                    if contains(paths(i),newfile)
                        newfile = "var1" + var1 + "_var2" + var2 + "_var3" + var3 + "_" + k + ".data";
                        k = k + 1;
                        i = 1;
                    else
                        i = i + 1;
                    end
                end
                movefile(d(idx).name, newfile) %detta kommandot byter namnet

                %navigerar in till data filen med tif bilderna
                cd(newfile);

                %skapar en txt fil med specifik info om datan
                writetable(table(var1, var2, var3, 'VariableNames', {'var1', 'var2', 'var3'}), 'parameterinfo.txt')

                %flyttar upp filen ett steg
                cd(oldFolder + "\" + "unformatted data")
                movefile(newfile, oldFolder)

                %navigera tillbaka till executable path
                cd(oldFolder);

                %flyttar filen till sitt respektive ställe
                movefile(newfile, "data"), cd("data")
                %skapar en tom string för lagrings path
                path = "";
    
                %itererar varje variabel
                for i = 1:length(vars)
                    if i > length(vars)
                        break
                    end
    
                        %kollar om en fil med specifika variabelvärdet redan
                        %finns, annars skapar en ny mapp, flyttar datan och
                        %bytar till den mappen
                        if ~exist(vars(i), 'dir')
                            mkdir(string(vars(i)))
                        end
                        movefile(newfile, string(vars(i)))
                        cd(string(vars(i)))
                        %lagrar adressen till path
                        path = path + "/" + string(vars(i));
                 end
                

                %återvänder till execute mapp
                cd(oldFolder)

                %print till console för användaren att se vad som hänt
                fprintf("Ny filnamn: " + newfile + "\n")
                fprintf("Lagrad i: " + path + "\n")
            
            end
            function paths = findDataPaths()

                %denna kod itererar igenom alla mappar i vår data och
                %hittar alla bilder som vi tagit, och returnerar
                %addresserna till dessa

                %OBS: denna kod skulle nyttjas vid parameter analysen, men
                %eftersom vi kanske skippar det så är denna kod kanske
                %onödig

                %hittar alla filer i data
                files = dir(fullfile("data", '**\*.*'));

                %filtrerar bort allt som inte är en mapp
                filepaths = {files([files.isdir]).folder};

                %tar bort dubbletter
                filepaths = unique(filepaths);
                
                %skapar en tom address vektor
                paths = [];

                %itererar igenom alla addresser och sparar endast dem som
                %innehåller .data i namnet
                for i = 1:length(filepaths)
                    if contains(filepaths(i), '.data')
                        paths = cat(1, paths, string(filepaths(i)));
                    end
                end
            end
            function matrix = calcMatrix()

                %den här koden nyttjar först findDataPaths() för att hitta
                %alla addresser till vår data, därefter lagrar alla värden
                %(såsom intensitetsprofiler, standardavvikelser och
                %parameter värden) i en ny samlad matris

                oldFolder = cd;
                datafiles = ALLfuncs.findDataPaths;
                matrix = zeros(height(datafiles), 4);

                %itererar igenom all vår data
                for i = 1:length(datafiles)

                    %beräknar intensitets värden och lagrar dem i matrisen
                    values = ALLfuncs.calcIntensity(datafiles(i),"");
                    cd(datafiles(i))
                    
                    %lagrar informationen om undersökningen (vilka
                    %variabler och värden på dem) som nyttjades i matrisen
                    info = readmatrix("parameterinfo.txt");
                    for k = 1:length(info)
                        matrix(i, k) = info(k);
                    end
                        matrix(i,length(info)+1) = std(values);
                        cd(oldFolder)
                end
            end
            function plot3Ddata(var1,var2,value,matrix)

                %den här koden tar fram matrisen från calcMatrix() och
                %plottar datan i en 3D plot, med avseende på variabel 1 i
                %x-led och variabel 2 i y-led. Det behövs minst tre
                %punkter för att skapa en yta!! Variabel 3 är den som hålls
                %konstant = value

                %OBS: denna kod skulle nyttjas vid parameter analysen, men
                %eftersom vi kanske skippar det så är denna kod kanske
                %onödig

                %hittar den variabel som ska hållas konstant
                choices = [1 2 3];
                choices(choices == var1) = [];
                choices(choices == var2) = [];
                
                %sorterar bort de värden som inte innehåller den variabel
                %som ska hållas konstant
                k = height(matrix);
                i = 1;
                while i <= k
                    if matrix(i,choices) ~= value
                        matrix(i,:) = [];
                        i = 1;
                        k = k - 1;
                    else
                    i = i + 1;
                    end
                end
                
                [xq,yq] = meshgrid(0:1:100, 0:1:100);

                %skapar matris med sammanhängande punkter 
                figure
                vq = griddata(matrix(:,var1), matrix(:,var2), matrix(:,4),xq,yq); %byt ut matrix rows/columns om man vill plotta annat
                mesh(xq,yq,vq)
                hold on
                plot3(matrix(:,1), matrix(:,2), matrix(:,4),'o')
                ylabel("variable 1"),xlabel("variable 2"),zlabel("Standard deviation")

                %hittar den variabel som man vill hålla konstant
                if choices == 1
                    str = "variabel 1";
                elseif choices == 2
                    str = "variabel 2";
                elseif choices == 3
                    str = "variabel 3";
                end

                title("Let " + str + " = " + matrix(1,choices))
            end
            function plot2Ddata(var1, value1, value2,matrix)

                %den här koden tar fram matrisen från calcMatrix() och
                %plottar datan i en 2D plot, med avseende på en variabel,
                %där de andra två måste hållas konstanta och anges som
                %ingångsparametrar.

                %OBS: denna kod skulle nyttjas vid parameter analysen, men
                %eftersom vi kanske skippar det så är denna kod kanske
                %onödig

                %sorterar en vektor med indexet som ska få variera
                choices = [1 2 3];
                choices(choices == var1) = [];
                values = [value1 value2];

                %sorterar bort värden som inte kommer användas
                for x = 1:length(choices)
                    k = height(matrix);
                    i = 1;
                    while i <= k
                        if matrix(i,choices(x)) ~= values(x)
                            matrix(i,:) = [];
                            i = 1;
                            k = k - 1;
                        else
                            i = i + 1;
                        end
                    end
                end
                
                stem(matrix(:,var1), matrix(:,4))
                
                %hämtar de labels för grafen som har väljts
                str = ["" ""];
                for i = 1:length(choices)
                    if choices(i) == 1
                        str(i) = "var1";
                    elseif choices(i) == 2
                        str(i) = "var2";
                    elseif choices(i) == 3
                        str(i) = "var3";
                    end
                end
                
                vars = ["var1" "var2" "var3"];
                xlabel(vars(var1)), ylabel("Standard Deviation")
                title(str(1) + " = " + value1 + " & " + str(2) + " = " + value2)

            end
            function plot4Ddata(var1,matrix)

                %denna kod nyttjar matrisen från calcMatrix och plottar den
                %i en 3Dplot, och varierar en variabel över tid, så man får
                %en animation. Koden funkar inte, så det är inte värt att
                %använda.

                %OBS: denna kod skulle nyttjas vid parameter analysen, men
                %eftersom vi kanske skippar det så är denna kod kanske
                %onödig

                matrix = sortrows(matrix,var1);
                t = matrix(:,var1);

                choices = [1 2 3];
                choices(choices == var1) = [];

                for i = 1:height(t)
                    t(i);
                    ALLfuncs.plot3Ddata(choices(1),choices(2),t(i),matrix)
                    pause(1)
                    if i ~= height(t)
                        clf
                    end
                end
            end
            function table = showAllData()

                %returnerar en tabell med all tillgänglig data

                %OBS: denna kod skulle nyttjas vid parameter analysen, men
                %eftersom vi kanske skippar det så är denna kod kanske
                %onödig

                matrix = num2cell(ALLfuncs.calcMatrix);
                paths = num2cell(ALLfuncs.findDataPaths);
                table = [matrix paths];
                titles = ["var1", "var2", "var3", "std", "location"];
                table = [titles; table];
            end
            function table = findSpecificData(var1,var2,var3)

                %returnerar en table med info om en specifik data punkt

                %OBS: denna kod skulle nyttjas vid parameter analysen, men
                %eftersom vi kanske skippar det så är denna kod kanske
                %onödig

                table = ALLfuncs.showAllData;
                table(1,:) = [];
                var = [var1 var2 var3];

                for i = 1:width(table)-2
                    for k = 1:height(table)
                        if double(table(k,i)) ~= var(i)
                            table(k,:) = 0;
                        end
                    end
                end

                indices = double(table(:,2))==0;
                table(indices,:) = [];
            end
        end
end