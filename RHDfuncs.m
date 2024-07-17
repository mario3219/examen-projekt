classdef RHDfuncs
        methods(Static)

            %den här klassen nyttjades under rhodamine labbarna
            
            function data = importData(inputdata,outputdata)

                %returnerar en tabell med värden som togs i början av
                %kanalen, och i slutet av kanalen, tillsammans med deras
                %path om man vill nyttja dem

                %ingångsparametrar:
                %inputdata: den mapp som har alla datavärden som togs i
                %början av kanalen
                %tex "D:\Mina Actual Dokument\Skola\EEML05\data files\hot vs cold experiments\input"

                %outputdata: den mapp som har alla datavärden som togs i
                %slutet av kanalen
                %tex "D:\Mina Actual Dokument\Skola\EEML05\data files\hot vs cold experiments\output"

                %lagrar path där ALLfuncs.m körs ifrån
                oldFolder = cd;
                
                %läser in alla filer i inputdata
                cd(inputdata)
                input = dir();
                index = [input.isdir];
                input = input(index);
                input = {input(3:end).name};                
                cd(oldFolder)

                %läser in alla filer i outputdata
                cd(outputdata)
                output = dir();
                index = [output.isdir];
                output = output(index);
                output = {output(3:end).name};
                cd(oldFolder)

                %läser in vilka temperaturer som nyttjades under försöken.
                %Detta görs genom att läsa in 'namnet' på varje fil. Dvs
                %vid varje försök så namngavs varje fil med vilken
                %temperatur som nyttjades

                %tex i "hot vs cold experiments\input" hittar man massa
                %mappar med olika temperaturer, det är dessa namn som
                %temperatur värdena hämtas ifrån, tex '21_1'

                temps = zeros(length(output),1);

                %itererar igenom varje fil
                for i = 1:1:length(input)
                    %här läses namnet in, och tar bort '_1' 
                    str = split(string(output(i)),"_");
                    temps(i) = double(str(1));
                end

                %skapar vektorer med path till varje data punkt
                input = inputdata + "\" + input;
                output = outputdata + "\" + output;

                %lagrar all data i en tabell och returnerar denna
                data = [string(input(:)) string(output(:)) temps];

            end
            function plotTemperatureLoss(data)

                %plottar medelintensiteten för varje temperatur i y-led,
                %och temperaturen för den intensiteten i x-led. Denna kod
                %nyttjades för att beräkna temperatur loss över kanalen som
                %funktion av temperatur

                %ingångsparametrar:
                %data: den tabell som beräknas från importData

                y = zeros(height(data),1);
                x = zeros(height(data),1);

                %itererar igenom varje data punkt från tabellen 'data'
                for i = 1:1:height(data)
                    %hämtar temperaturen från data och algrar i x-vektorn
                    x(i) = double(data(i,3));
                    %beräknar medelvärdena för ingången och utgången av
                    %kanalen för den temperaturen
                    meanoutput = nanmean(ALLfuncs.calcIntensity(data(i,2), data(i,2) + "\background_1"));
                    meaninput = nanmean(ALLfuncs.calcIntensity(data(i,1),data(i,1) + "\background_1"));
                    %lagrar skillnaden mellan output och input i y-vektorn
                    y(i) = meanoutput-meaninput;
                end
                figure
                plot(x,y),xlabel("Temperature (C)"),ylabel("Delta Intensity"),title("Temperature loss (Output-Input)")
            end
        end
end