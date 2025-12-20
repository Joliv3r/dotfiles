target="/home/joliver/"
stowdir="/home/joliver/.dotfiles/"
dirs_with_dot_config=(
  "alacritty"
  "i3"
  "polybar"
  "qutebrowser"
)

dirs_without_dot_config=(
  "zathura"
  "zsh"
)

for dir in "${dirs_without_dot_config[@]}"; do
  stow -d "$stowdir$dir/" -t "$target" .
done

for dir in "${dirs_with_dot_config[@]}"; do
  mkdir -p "$target.config/$dir"
  stow -d "$stowdir$dir/" -t "$target" .
done
