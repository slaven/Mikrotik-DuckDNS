# RouterOS v6.x DuckDns update script

# Set your DuckDns subdomain and token
:global duckDnsSubdomain "subdomain"
:global duckDnsToken "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Set your (WAN) interface
:global duckDnsInterface "myinterface"

# Do not edit below
:global duckDnsHost "$duckDnsSubdomain.duckdns.org"
:global duckDnsIP [:resolve server=8.8.8.8 $duckDnsHost];   # specify DNS server so if you have a local DNS entry for the URL it doesn't affect outcome.
:global duckDnsNewIP [ /ip address get [/ip address find interface=$duckDnsInterface ] address ]

:if ([ :typeof $duckDnsNewIP ] = nil ) do={
    :log info ("DuckDNS: No ip address on $duckDnsInterface")
} else={
    :for i from=( [:len $duckDnsNewIP] - 1) to=0 do={
        :if ( [:pick $duckDnsNewIP $i] = "/") do={
            :set duckDnsNewIP [:pick $duckDnsNewIP 0 $i];
        }
    }

    :if ($duckDnsIP != $duckDnsNewIP) do={
        :log info ("DuckDNS: Old IP: $duckDnsIP -> New IP: $duckDnsNewIP")
        :local str "https://www.duckdns.org/update\?domains=$duckDnsSubdomain&token=$duckDnsToken&ip=$duckDnsNewIP"
        /tool fetch url=$str mode=https dst-path="/DuckDNS.$duckDnsHost"
        :delay 1
        :local str [/file find name="DuckDNS.$duckDnsHost"];
        /file remove $str
        :local duckDnsIP $duckDnsNewIP
        :log info "DuckDNS: IP updated to $duckDnsNewIP"
    } else={
        :log info "DuckDNS: dont need changes";
    }
}
