#!/usr/bin/bash

function installed_found {
    set +e
    found=$(type "$1" 2>/dev/null || echo "")
    set -e
    if [ -z "found" ]; then
        echo "No install of $1 found"
        return 1;
    else
        echo "$1 already installed"
        return 0;
    fi
}

if ! (installed_found git); then
    apt-get install -y git
fi

if ! (installed_found go); then
    apt-get install -y go
fi

if ! (installed_found gofish); then
    echo "Installing gofish..."
    curl -fsSL https://raw.githubusercontent.com/fishworks/gofish/main/scripts/install.sh | bash
    gofish init
fi

if ! (installed_found helm); then
    gofish install helm
fi

shadowserver=$HOME/go/bin/shadowsocks-server
if [ -f "$shadowserver" ]; then
    echo "Shadowsocks server had been installed"
else
    echo "Intalling shadowsocks..."
    go get github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-server
    go install $HOME/go/src/github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-server
fi

cat <<EOF > server-multi-port.json
{
	"port_password": {
		"8387": "foo",
		"8388": "bar"
	},
	"method": "aes-256-cfb",
	"timeout": 600
}
EOF

echo "Run the following command to start the server"
echo "    ~/go/bin/shadowsocks-server -c server-multi-port.json &"
