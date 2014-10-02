
#Yokin's Wake on LAN ASP.NET

Yokin's Wake on LAN is a small piece of ASP.NET program to manage some number of computers which are deployed in LAN to power of and get current power status.

##Features

 - HTML base simple operation
 - Pinging to probe if the PC is on or off
 - Send Wake-on-LAN packet to turn the PC on

##Demo
visit our website http://www.yo-ki.com/Software/wol/

##Where to Work

Microsoft IIS 6.0 or later ( where ASP.NET 4.0 is enabled)

##How to Install

###1. place 2 files
place 2 files any location of web server.

 - Default.aspx
 - wol_hosts.xml
 
 in some environments wol_hosts setting file may need to be hidden and inaccessible from public. In such a case, rewrite the line to point to wol_hosts.xml file in Default.aspx.

        static String XmlFilePath = "wol_hosts.xml";

###2. add PCs in wol_hosts.xml file

    <hosts>
      <host name="Computer Name 1"
       mac-address="00:00:00:00:00:00"
       ip-address="192.168.0.1"
       <wol broadcast-address="192.168.0.255" />
      </host>
     </hosts>

**name** and **mac-address** is always required. **ip-address** is optional and used to Ping.
broadcast-address is used to limit the network range in the case the web server has 2 or more network interfaces and different subnetwork like global internet and local network.

##Security Caution
If the webserver is public, you might need to limit access to **Default.aspx** file and **wol_hosts.xml** file.

##Public Domain (Unlicense)


This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org>

