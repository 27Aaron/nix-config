# Binary cache registry shared by the system nix settings.
{
  substituters = [
    "https://cache.numtide.com" # llm-agents prebuilds (numtide)
    "https://attic.xuyh0120.win/lantian" # CachyOS kernel prebuilds (xddxdd)
  ];
  trustedPublicKeys = [
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" # cache.numtide.com
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" # attic.xuyh0120.win/lantian
  ];
}
