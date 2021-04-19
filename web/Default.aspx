<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Net.Sockets" %>
<%@ Import Namespace="System.Web.Services" %>
<!DOCTYPE html>

<script runat="server">
    static String XmlFilePath = "wol_hosts.xml";
    static int PingTimeout = 3000; /* miliseconds */
    static XmlDocument _xmlDataSource = null;
    static object lockXmlDataSourceObject = new object();
    static XmlDocument xmlDataSource {
        get 
        {
            String key = HttpContext.Current.Request.RawUrl + "_xmlDataSource";
            lock (lockXmlDataSourceObject)
            {
                if (_xmlDataSource == null)
                {
                _xmlDataSource = (XmlDocument)HttpContext.Current.Cache.Get(key);
                    if( _xmlDataSource == null ){
                        var filename = HttpContext.Current.Server.MapPath(XmlFilePath);
                        if( System.IO.File.Exists(filename) ){
                            _xmlDataSource = new XmlDocument();
                            _xmlDataSource.Load( filename );
                            HttpContext.Current.Cache.Add( key, _xmlDataSource, new CacheDependency(filename), Cache.NoAbsoluteExpiration, Cache.NoSlidingExpiration, CacheItemPriority.Default, 
                                new CacheItemRemovedCallback( delegate(String _key, object value, CacheItemRemovedReason reason ){
                                    _xmlDataSource = null;
                                }));
                        }
                    }
                }
            }
            return _xmlDataSource;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        HostsGridView.DataSource = new XmlDataSource { EnableCaching = true, DataFile = XmlFilePath, XPath = "//host" };
        HostsGridView.DataBind();
    }

    private static void WakeUp(byte[] mac, String broadCastAddress)
    {
        byte[] packet = new byte[17 * 6];
        for (int i = 0; i < 6; i++)
            packet[i] = 0xFF;
        for (int i = 1; i <= 16; i++)
            for (int j = 0; j < 6; j++)
                packet[i * 6 + j] = mac[j];
        System.Net.IPAddress wolIPAddr = String.IsNullOrEmpty(broadCastAddress) ? System.Net.IPAddress.Broadcast : System.Net.IPAddress.Parse(broadCastAddress);
        int wolPortAddr = 7;
        System.Net.IPEndPoint wolEndPoint = new System.Net.IPEndPoint(wolIPAddr, wolPortAddr);
        Socket client = new Socket(wolEndPoint.AddressFamily, SocketType.Dgram, ProtocolType.Udp);
        try
        {
            client.Connect(wolEndPoint);
            client.Send(packet, 0, packet.Length, SocketFlags.None);
        }
        catch (SocketException ex)
        {
            throw ex;
        }
        finally
        {
            client.Close();
        }
    }

    [WebMethod]
    static public bool Ping( int index )
    {
        var xml = xmlDataSource;
        var node = (XmlElement)xml.SelectSingleNode("//host[" + (index + 1).ToString() + "]");
        String address = node.GetAttribute("ip-address");
        System.Net.NetworkInformation.Ping ping = new System.Net.NetworkInformation.Ping();
        try
        {
            System.Net.NetworkInformation.PingReply reply = ping.Send(address, PingTimeout);
            if (reply.Status == System.Net.NetworkInformation.IPStatus.Success)
                return true;
        }
        catch
        {
        }
        return false;
    }
    [WebMethod]
    static public void Wakeup( int index )
    {
        var xml = xmlDataSource;
        var node = (XmlElement)xml.SelectSingleNode("//host[" + (index+1).ToString() + "]");
        String mac = node.GetAttribute("mac-address"), broadCastAddress = (String) DataBinder.Eval( node.SelectSingleNode("wol[@broadcast-address]/@broadcast-address"), "Value" );
        String[] macs = mac.Split(":-".ToCharArray());
        byte[] macb = new byte[macs.Length];
        for (int i = 0; i < macb.Length; i++) macb[i] = Byte.Parse(macs[i], System.Globalization.NumberStyles.HexNumber);
        WakeUp(macb, broadCastAddress);
    }
</script>
<!DOCTYPE html>
<html>
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yokin's Wake On LAN</title>
    <script src="//code.jquery.com/jquery-1.11.1.min.js" type="text/javascript"></script>
    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" />

    <!-- Optional theme -->
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" />

    <!-- Latest compiled and minified JavaScript -->
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" type="text/javascript"></script>

    <style type="text/css">
        .round-button, .round-button:hover, .round-button:focus {
            cursor: pointer;
            display: inline-block;
            vertical-align: baseline;
            background-color: #f7f7f7;
            background-image: -webkit-gradient(linear, left top, left bottom, from(#f7f7f7), to(#e7e7e7));
            background-image: -webkit-linear-gradient(top, #f7f7f7, #e7e7e7); 
            background-image: -moz-linear-gradient(top, #f7f7f7, #e7e7e7); 
            background-image: -ms-linear-gradient(top, #f7f7f7, #e7e7e7); 
            background-image: -o-linear-gradient(top, #f7f7f7, #e7e7e7); 
            color: #a7a7a7;
            margin: 0 0.4em;
            position: relative;
            text-align: center;
            border-radius: 50%;
            padding: 10%;
            box-shadow: 0px 3px 8px #aaa, inset 0px 2px 3px #fff;
        }
        .round-button:focus {
        }
        .round-button:hover {
            text-decoration: none;
            background: #f5f5f5;
        }
        .round-button.green {
            color: #31ff08;
        }
        .checking {
            background-color: #ffea00;
            background-image: -webkit-gradient(linear, left top, left bottom, from(#ffea00), to(#e2de00));
            background-image: -webkit-linear-gradient(top, #ffea00, #e2de00); 
            background-image: -moz-linear-gradient(top, #ffea00, #e2de00); 
            background-image: -ms-linear-gradient(top, #ffea00, #e2de00); 
            background-image: -o-linear-gradient(top, #ffea00, #e2de00); 
         
        }
        .each-item{
            text-align: center;
            padding: 1em;
            margin-bottom: 1em;
            border: solid 1px #e7e7e7;
            border-radius: 0.6em;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <script type="text/javascript">
                Yokins = {
                    WOL: {
                        Wakeup: function( index, success, fail ){
                            PageMethods.Wakeup(index, function (result) {
                                if (success) success(result);
                            }, fail);
                        },
                        Ping: function (index, retry, success, fail) {
                            var retryCount = isNaN(retry) ? 1 : retry;
                           
                            function _ping(index, success, fail) {
                                PageMethods.Ping(index, success, fail);
                            }
                            function _success(result){
                                if (result || --retryCount < 1) {
                                    if (success) success(result);
                                } else {
                                    _ping(index, _success, fail);
                                }
                            }
                            _ping(index, _success, fail);
                        }
                    }
                };
         
                $(document).ready(function () {
                    function Ping(btn, i, retry ){
                        var buttons = btn.closest(".each-item").find(".round-button");
                        buttons.addClass("checking");
                        Yokins.WOL.Ping(i, retry, function(result){
                            if( result){
                                buttons.removeClass("checking").addClass("green");
                            } else {
                                buttons.removeClass("checking").removeClass("green");
                            }
                        },
                        function(result){
                            alert( result.get_message());
                            buttons.removeClass("checking");
                        });
                    }
                    var table = $("#hostList");
                    table.on("click", ".ping-button", function(){
                        var btn = $(this);
                        Ping(btn, btn.data("index"), 1);
                    });
                    table.on("click", ".wake-button", function () {
                        var btn = $(this);
                        var i = btn.data('index');
                        btn.addClass("checking");
                        Yokins.WOL.Wakeup(i, function (result) {
                            Ping(btn, i, 3/*retry*/);
                        },
                            function (result) {
                                alert(result.get_message());
                                btn.removeClass("checking");
                            });
                    });
                    table.find(".wake-button").each(function () {
                        Ping( $(this), $(this).data('index'), 1);
                    });

                });
            </script>
            <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true">
            </asp:ScriptManager>
            <div class="container">
                <h2>Yokin&#39;s Wake On LAN</h2>
                <div class="row" id="hostList">
                <asp:Repeater ID="HostsGridView" runat="server">
                    <ItemTemplate>
                        <div class="col-xs-6 col-sm-4 col-md-3">
                            <div class="each-item">
                                <div>
                                    <a class="round-button wake-button" title="Wake up!" data-index="<%# Container.ItemIndex %>">
                                        <i class="glyphicon glyphicon-off" style="font-size: 78px;"></i>
                                    </a>
                                </div>
                                <h3><%# Eval("name") %></h3>
                                <div class="text-muted"><%# Eval("mac-address") %></div>
                                <div class="text-muted"><%# Eval("ip-address") %></div>
                                <a href="#" class="btn btn-default ping-button" title="Ping" data-index="<%# Container.ItemIndex %>">
                                    <i class="glyphicon glyphicon-refresh"></i> Ping
                                </a>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                </div>
                <hr />
                <div class="text-center">
                    <b>Yokin's Wake ON LAN v.2.1</b><br />
                    <cite>Supported by <a target="_blank" href="http://www.yo-ki.com/">Yokin'soft</a></cite>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
