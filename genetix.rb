#!/usr/bin/ruby

lineArray = Array.new
allele1 = String.new
allele2 = String.new
true1 = String.new
true2 = String.new

STDIN.each_line do |line|

        lineArray = line.split(/\t/)

        if (lineArray.at(0).length==0) then
            true1 = lineArray.at(6)
            true2 = lineArray.at(7)
        else
            allele1 = lineArray.at(6)
            allele2 = lineArray.at(7)
        end
           

        if(allele1.length>0 or allele2.length>0) then
            lineArray[11] = 1

            if((allele1==true1 and allele2==true2) or (allele1==true1 and allele2.length==0)) then
                lineArray[12]=1
            else
                lineArray[12]=0
            end

        else
            lineArray[11]=0
        end

        puts lineArray.join("\t")
end
