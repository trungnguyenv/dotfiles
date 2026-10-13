{ ... }:
{
  home.shellAliases = {
    nhn = "claude --dangerously-skip-permissions";
    hn = "nhn --continue";
    cdx = "codex resume --dangerously-bypass-approvals-and-sandbox";
    hl = "herdr --remote homelab --remote-keybindings server";
  };
}
