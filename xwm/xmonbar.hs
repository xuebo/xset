Config { font = "-*-Fixed-Bold-R-Normal-*-13-*-*-*-*-*-*-*"
       , bgColor = "black"
       , fgColor = "grey"
       , position = Static { xpos = 0 , ypos = 0, width = 1215, height = 20 }
       , lowerOnStart = True
       , allDesktops = True
       , commands = [ Run Weather "EGPF" ["-t","<tempF>F","-L","64","-H","77","--normal","green","--high","red","--low","lightblue"] 36000
                    , Run Cpu ["-t","C <total>%", "-L","3","-H","50","--normal","green","--high","red"] 10
                    -- , Run Battery ["-t","<acstatus>", "Battery <left>% <timeleft>", "-L","50","-H","75","-h","green","-n","yell","-l","red"] 10
                    , Run Battery ["-t", "Batt: <left>% <timeleft> <acstatus><watts>",
                                   "-L", "10", "-H", "80", "-p", "3",
                                   "-l", "red", "-h", "green",
                                   "--", "-O", "<fc=green>On</fc>", "-i", "On", "-o", "Off",
                                   "-L", "-15", "-H", "-5",
                                   "-l", "red", "-m", "blue", "-h", "green"] 10
                    , Run Memory ["-t","M <usedratio>%"] 10
                    , Run Swap ["-t","S <usedratio>%"] 10
                    , Run Date "%b/%d %H:%M:%S %a" "date" 10
                    , Run Network "eth0" ["-t", "N<rx>:<tx> Kbps", "-L", "0", "-H", "32", "--normal", "green", "--high", "red"] 10
                    , Run StdinReader
                    -- , Run CpuFreq ["-t","<cpu0>"] 10
                    -- , Run ThermalZone 0 ["-t","<temp>C","-L","40","-H","79","-h","red","-n","yellow","-l","green"] 10
                    -- , Run Volume "default" "Master" [] 10
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%StdinReader% }{ | %eth0% | %cpu% %memory% | %battery% | <fc=#ee9a00>[%date%]</fc> [%EGPF%] []"
       }
