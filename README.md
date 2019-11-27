# ServerShell
There is some server shell

## add_user_key.sh is for add user setting.
wget https://raw.githubusercontent.com/kenneth-lin/ServerShell/master/add_user_key.sh -O add_user_key.sh && chmod +x add_user_key.sh


## brook.sh is for brook setting.
wget https://raw.githubusercontent.com/kenneth-lin/ServerShell/master/brook.sh -O brook.sh && chmod +x brook.sh

## shadowsocks-libev.sh is for shadowsocks setting.
wget https://raw.githubusercontent.com/kenneth-lin/ServerShell/master/shadowsocks-libev.sh && chmod +x shadowsocks-libev.sh

## shadowsocks-manager.sh is for shadowsocks manager.
wget https://raw.githubusercontent.com/kenneth-lin/ServerShell/master/shadowsocks-manager.sh && chmod +x shadowsocks-manager.sh

## shadowsocks-libev.sh is for shadowsocks setting with password.
wget https://raw.githubusercontent.com/kenneth-lin/ServerShell/master/shadowsocks-pw.sh && chmod +x shadowsocks-pw.sh && sudo ./shadowsocks-pw.sh install $pw $port $encrypted

## install tcp_bbr to accelerate.
wget --no-check-certificate https://raw.githubusercontent.com/kenneth-lin/across/master/bbr.sh && chmod +x bbr.sh && sudo sh ./bbr.sh && sudo reboot
