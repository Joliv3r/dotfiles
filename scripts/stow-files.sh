target="/home/joliver/"
stowdir="/home/joliver/.dotfiles/"
dirs_with_dot_config=(
  "alacritty"
  "i3"
  "polybar"
  "qutebrowser"
  "zathura"
)

dirs_without_dot_config=(
  "zsh"
)

for dir in "${dirs_without_dot_config[@]}"; do
  echo "Handling $dir"
  stow -d "$stowdir$dir/" -t "$target" .
done

for dir in "${dirs_with_dot_config[@]}"; do
  echo "Handling $dir"
  mkdir -p "$target.config/$dir"
  stow -d "$stowdir$dir/" -t "$target.config/$dir" .
done
