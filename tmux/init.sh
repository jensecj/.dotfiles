running=$(ps -e | grep tmux)

if [[ ! -z $running ]];
then
    echo "tmux is already running";
    exit 1
fi

tmux new-session -d -s network -n vpn -c /home/jens/.nordvpn
tmux send-keys -t vpn C-l "./run.sh "
tmux new-window -d -a -t vpn -n ufw -c /
tmux send-keys -t ufw C-l "_ ufw status" Enter
tmux new-window -d -a -t vpn -n dnscrypt -c /
tmux send-keys -t dnscrypt C-l "start_dnscrypt" Enter

tmux new-session -d -s daemons_news -n dunst -c /
tmux send-keys -t dunst C-l "dunst -conf /home/jens/.dotfiles/dunstrc" Enter
tmux new-window -d -a -t dunst -n rtags -c /
tmux send-keys -t rtags C-l "rtagsd"
tmux new-window -d -a -t dunst -n xidlehook -c /
tmux send-keys -t xidlehook C-l "start_xidlehook" Enter
