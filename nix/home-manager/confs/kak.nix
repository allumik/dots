{ config, lib, pkgs, ... }:

{
  programs.kakoune = {
    enable = true;
    config = {
    	indentWidth = 2;
    	tabStop = 2;
    	autoReload = "yes";
    	alignWithTabs = false;
    	scrollOff.lines = 5;
    	ui.statusLine = "top";
    };
    plugins = with pkgs.kakounePlugins; [
      kak-fzf
      kak-auto-pairs
      kak-buffers
      kak-vertical-selection
      kakoune-extra-filetypes
    ];
  };
}
