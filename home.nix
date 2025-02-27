# This file defines the configuration of the user profile
# This module is a self-contained single function that takes some inputs and produces some outputs.
{ config, lib, pkgs, ... }:
let
  username = "Aventrius";
in {
	xdg.userDirs = {
		enable = true;
		createDirectories = true;

		extraConfig = {
			XDG_MOUNTPOINT_DIR = "${config.home.homeDirectory}/Mountpoints";
			XDG_DISLOCKER_DIR = "${config.home.homeDirectory}/Mountpoints/Dislocker";
			XDG_UNLOCKED_DIR = "${config.home.homeDirectory}/Mountpoints/Unlocked";
			XDG_USB_DIR = "${config.home.homeDirectory}/Mountpoints/USB";
			XDG_VPNCONFIG_DIR = "${config.home.homeDirectory}/vpnconfig";
		};
	};
	
	services.polybar = {
		enable = true;
		package = pkgs.polybar.override {
			i3Support = true;
		};
		script = ''
			polybar mybar &
		'';

    settings = {
      "colors" = {
        background = "#14141f";
        foreground = "#e3c8e6";
        primary = "#F5E0DC";
        secondary = "#F28FAD";
        alert = "#F8BD96";
      };

			"module/battery" = {
				type = "internal/battery";
				
				battery = "BAT0"; 
				
				full-at = 98;
				label-full = "  %percentage%%";
				label-charging = " %percentage%%";
				label-discharging = "  %percentage%%";
			};

      "module/i3" = {
        type = "internal/i3";
        pin-workspaces = true;  
        enable-click = true;  
        strip-wsnumbers = true;
        index-sort = true;
        format = "<label-state> <label-mode>";
        label-mode = "%mode%";
        label-focused = "%index%";
        label-focused-foreground = "#ff06b5";
        label-focused-background = "#14141f";
        label-focused-padding = 1;
        label-unfocused = "%index%";
        label-unfocused-padding = 1;
        label-visible = "%index%";
        label-visible-padding = 1;
        label-urgent = "%index%";
      };

      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = "%Y-%m-%d %H:%M";
      };

      "bar/mybar" = {
			  font-0 = "JetBrainsMono Nerd Font:size=15;1"; # Increase the "size=X" part
        width = "100%";
        height = 40;
        background = "\${colors.background}";
        foreground = "\${colors.foreground}";
				padding = 2;
				radius = 20;
				border-size = 2;
				border-color = "#1e1e2e";
				dim-value = 0.6;

        modules-left = "i3";
        modules-center = "date";
        modules-right = "battery";
      };
    };
	};

	services.picom = {
		enable = true;
		backend = "glx";
		activeOpacity = 0.9;
		inactiveOpacity = 0.8;
		fade = true;
		fadeDelta = 5;
		settings = {
			blur = {
				kern = "3x3box";
				method = "kawase";
				strength = 10;
			};
			corner-radius = 20;
		};
	};

  home = {
    # with tells Nix, for any variable being used in the following expression, if it's not declared already, check whatever's in with.
    packages = with pkgs; [
      hello
      cowsay 
      lolcat
      i3
			lua
			tmux
			nodePackages.pyright
			nodePackages.typescript-language-server
			python3Packages.i3ipc
			clang-tools
			rust-analyzer
			catppuccin
			lazygit
			(pkgs.nodePackages.vscode-langservers-extracted)
			(pkgs.nodePackages."@tailwindcss/language-server")
			feh
			light
			dislocker
			vlc
			prismlauncher
			zulu8
			alsa-utils
			ranger
			zathura
			busybox
			xclip
			python311
			python311Packages.pip
			picom
			fastfetch
			kitty
    ];

		# Replace youruserdir with your user directory name
		# add the image file to the correct path
		file.".config/fastfetch/config.jsonc" = {
			text = ''
			{
				"$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
				"logo": {
					"type": "kitty",
					"source": "/home/Aventrius/anna.png",
					"width": 40,
					"preserveAspectRatio": true
				},
				"modules": [
					"title",
					"separator",
					"os",
					"host",
					"kernel",
					"uptime",
					"packages",
					"shell",
					"display",
					"de",
					"wm",
					"wmtheme",
					"theme",
					"icons",
					"font",
					"cursor",
					"terminal",
					"terminalfont",
					"cpu",
					"gpu",
					"memory",
					"disk",
					"localip",
					"battery",
					"poweradapter",
					"locale",
					"break",
				]
			}
			'';
		};

		sessionVariables = {
			SSH_ASKPASS = "/bin/true";
			FASTFETCH_CONFIG_FILE = "$HOME/.config/fastfetch/config.jsonc";
		};
    inherit username;
    homeDirectory = "/home/${username}";

    stateVersion = "23.11";
  };
	
	xsession = {
		windowManager.i3 = {
			enable = true;
			package = pkgs.i3-gaps;

			config = {
				gaps.horizontal = 10;
				gaps.inner = 15;

				window.border = 0;
				window.hideEdgeBorders = "both";
				window.titlebar = false;
				window.commands = [
					{
						command = "for_window [class=\"^.*\"] border pixel 0";
						criteria = {
							class = "kitty";
						};
					}
				];
				keybindings = 
					let
						modifier = config.xsession.windowManager.i3.config.modifier;
					in lib.mkOptionDefault {
						"${modifier}+Shift+d" = "exec flameshot gui";
						"${modifier}+Return" = "exec kitty";
					};
				

				bars = [ ];
				startup = [{
					command = "pkill polybar; polybar mybar &";
					always = true;
					notification = false;
				}];


				floating.titlebar = false;
      };
    };
  };


	systemd.user.services.ssh-agent = {
		Unit = {
			Description = "SSH key agent";
			Before = [ "graphical-session.pre.target" ];
		};

		Service = {
			ExecStart = ''
				${pkgs.openssh}/bin/ssh-agent -D
			'';
			Restart = "always";
		};

		Install = { WantedBy = [ "default.target" ]; };
	};

  programs = {
		# add your github credentials
		git = {
			enable = true;
			userName = "yourgithubusername";
			userEmail = "yourgithubemail";
			extraConfig = {
				url."git@github.com:".insteadOf = "https://github.com/";
			};
		};
	
		ssh = {
			enable = true;
			extraConfig = ''
				Host github.com
					User git
					IdentityFile ~/.ssh/id_ed25519
					IdentitiesOnly yes
					AddKeysToAgent yes
			'';
		};

		lazygit = {
			enable = true;
			package = pkgs.catppuccin;
			settings = {
				gui.theme = {
					activeBorderColor = [ "#89b4fa" "bold" ]; 
					inactiveBorderColor = [ "#a6adc8" ]; 
					optionsTextColor = [ "#89b4fa" ]; 
					selectedLineBgColor = [ "#313244" ]; 
					selectedRangeBgColor = [ "#313244" ]; 
					cherryPickedCommitBgColor = [ "#45475a" ];
					cherryPickedCommitFgColor = [ "#89b4fa" ];
					unstagedChangesColor = [ "#f38ba8" ];
					defaultFgColor = [ "#cdd6f4" ];
					searchingActiveBorderColor = [ "#f9e2af" ];
				};
				showFileTree = true;
				authorColors = {
					"*" = "#b4befe";
				};
			};
		};

		bash = {
			enable = true;
			shellAliases = {
				ll = "ls -lah --color=auto";
			};
		};

		tmux = {
			enable = true;
		};

		alacritty = {
			enable = true;
			settings = {
				import = [ "${pkgs.catppuccin}/mocha/alacritty.toml" ];
				window = {
					opacity = 1;
					padding = {
						x = 20;
						y = 20;
					};
				};
				colors = {
					primary = {
						background = "#14141f";
						foreground = "#cdd6f4";
						dim_foreground = "#7f849c";
						bright_foreground = "#cdd6f4";
					};
					normal = {
					#	red = "#f38ba8";
					#	green = "#a6e3a1";
					#	yellow = "#f9e2af";
					#	blue = "#89b4fa";
					#	white = "#bac2de";
					# black = "#45475a";

						base = "#14141f";
						magenta = "#f5c2e7";
						cyan = "#b62eff";
						text = "#be82e0";
						blue = "#7573ff";
						teal = "#442ffa";
						sky = "#ffbde8";
						flamingo = "#ff99fd";
						lavender = "#c596ff";
						green = "#fa58d9";
						maroon = "#fa57d9";
						peach = "#de06ff";
						yellow = "#ff06B5";
						red = "#ff0059";
					};
					selection = {
						text = "#1e1e2e";
						background = "#f5e0dc";
					};
				};
			};
		};

		kitty = {
			enable = true;
			theme = "Catppuccin-Mocha";
		
			font = {
				size = 10;
				name = "JetBrainsMono";
			};

			extraConfig = ''
				# Window Settings
				font_size 12
				background_opacity 1.0
				window_padding_width 10

				# Colors
				foreground #cdd6f4
				background #14141f
				selection_foreground #1e1e2e
				selection_background #f5e0dc

				# Custom ANSI Colors (matches Alacritty)
				color0  #14141f
				color1  #ff0059
				color2  #fa58d9
				color3  #ff06B5
				color4  #7573ff
				color5  #f5c2e7
				color6  #b62eff
				color7  #bac2de
				color8  #45475a
				color9  #f38ba8
				color10 #3804d6
				color11 #bd61ff
				color12 #89b4fa
				color13 #ff99fd
				color14 #ffbde8
				color15 #cdd6f4
			'';
		};

    neovim = 
    let
      toLua = str: "lua << EOF\n${str}\nEOF\n";
			toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
    in {
      enable = true;
      defaultEditor = true;

      vimAlias = true;
      viAlias = true;
      vimdiffAlias = true;

      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
				nvim-treesitter.withAllGrammars
				cmp-nvim-lsp
				nvim-cmp
				luasnip
				nvim-autopairs
				catppuccin-nvim

				telescope-nvim
				telescope-file-browser-nvim
				plenary-nvim
				lazygit-nvim
				nvim-web-devicons

				gitsigns-nvim

				(nvim-treesitter.withPlugins (p: [
					p.tree-sitter-nix
					p.tree-sitter-vim
					p.tree-sitter-bash
					p.tree-sitter-lua
					p.tree-sitter-python
					p.tree-sitter-json
				]))

				{
					plugin = comment-nvim;
					config = toLua "require(\"Comment\").setup()";
				}

				{
					plugin = catppuccin-nvim;
					config = "colorscheme catppuccin";
				}

			];

			extraPackages = with pkgs; [
				tree-sitter
				ripgrep
				fd
			];

      extraLuaConfig = ''
				vim.g.mapleader = " "
				vim.g.maplocalleader = " "

        vim.wo.number = true
        vim.opt.relativenumber = true
	      vim.opt.tabstop = 2
				vim.opt.shiftwidth = 2
				vim.opt.expandtab = tre
				vim.bo.softtabstop = 2
				vim.api.nvim_set_keymap('n', '<leader>lg', ':LazyGit<CR>', { noremap = true, silent = true })

				-- catppuccin Anna
				require("catppuccin").setup {
					color_overrides = {
						latte = {},
						frappe = {},
						macchiato = {},
						mocha = {
							base = "#14141f",
							text = "#be82e0",
							blue = "#7573ff",
							teal = "#442ffa",
							sky = "#ffbde8",
							flamingo = "#ff99fd",
							lavender = "#c596ff",
							green = "#fa58d9",
							maroon = "#fa57d9",
							peach = "#de06ff",
							yellow = "#ff06B5",
							red = "#ff0059",
						},
						flavour = "mocha",
					},
				}
				vim.cmd.colorscheme "catppuccin-mocha"

				-- Makes the system clipboard include the unnamedplus register instead of just th "+ register.
				vim.opt.clipboard:append("unnamedplus")


vim.api.nvim_set_keymap('n', '<leader>b', ':split | terminal<CR>', { noremap = true, silent = true })

			-- Move between splits
			vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })

			-- Telescope file browser
			vim.keymap.set("n", "<leader>fb", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")

			-- Telescope
      require('telescope').setup {}

      --Telescope keybinds
      vim.api.nvim_set_keymap('n', '<leader>t', ':Telescope find_files<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>tg', ':Telescope live_grep<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>tb', ':Telescope buffers<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>th', ':Telescope help_tags<CR>', { noremap = true, silent = true })

				-- Setup LSP
				local lspconfig = require("lspconfig")

				-- Enable LSPs
				local servers = { "clangd", "pyright", "tsserver", "rust_analyzer", "html", "tailwindcss" }
				for _, lsp in ipairs(servers) do
					lspconfig[lsp].setup {}
				end

				-- Autocompletion setup
				local cmp = require'cmp'
				cmp.setup {
					mapping = cmp.mapping.preset.insert({
						['<C-Space>'] = cmp.mapping.complete(),
						['<CR>'] = cmp.mapping.confirm({ select = true }),
					}),
					sources = cmp.config.sources({
						{ name = 'nvim_lsp' },
						{ name = 'buffer' },
						{ name = 'path' },
					})
				}

				-- Enable auto-pairs
				require("nvim-autopairs").setup {}


				-- Enable Treesitter indentation
				require'nvim-treesitter.configs'.setup {
					indent = {
						enable = true
					}
				}
      '';
    };
  };
}
