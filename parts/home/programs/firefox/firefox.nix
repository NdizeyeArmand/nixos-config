{ inputs, lib, ... }:
let
	bookmarks = lib.importJSON ./bookmarks.json;
	
	commonSettings = {
    "browser.newtabpage.activity-stream.feeds.section.highlights" = true;
    "browser.newtabpage.activity-stream.showSponsored" = false;          
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;          
    "browser.newtabpage.activity-stream.feed.topsites" = false;
  	"browser.contentblocking.category" = "strict";

    "browser.startup.page" = 3;

		"browser.sessionstore.resume_from_crash" = true;

		"browser.sessionstore.max_resume_crashes" = -1;

		"browser.urlbar.suggest.openpage" = false;

		# Disable WebRTC IP leaking
	  "media.peerconnection.enabled" = false;

	  # Disable DNS prefetching
	  "network.dns.disablePrefetch" = true;

	  # Disable speculative connections
	  "network.http.speculative-parallel-limit" = 0;

	  # Disable captive portal detection (pings Mozilla)
	  "network.captive-portal-service.enabled" = false;

	  "privacy.resistFingerprinting" = false;

	  "privacy.fingerprintingProtection" = true;
		"privacy.fingerprintingProtection.overrides" = "-CSSPrefersColorScheme";

	  # Disable telemetry more thoroughly
	  "toolkit.telemetry.unified" = false;
	  "toolkit.telemetry.enabled" = false;

    "browser.theme.dark-private-windows" = true;
    "layout.css.prefers-color-scheme.content-override" = 2;
    "ui.systemUsesDarkTheme" = 1;

	  # Prevent pointer grab bug on Wayland compositors
	  "widget.gtk.ignore-bogus-leave-notify" = 1;
		"widget.use-xdg-desktop-portal.mime-handler" = 1;
	};    	
in
{
	home.file.".mozilla/firefox/profile_1/chrome" = {
	  source = "${inputs.firefox-css}/chrome";
	  recursive = true;
	};

	home.file.".mozilla/firefox/profile_1/chrome/userChrome.css" = {
		text = ''
	  @import url(tab_close_button_always_on_hover.css);
		@import url(tab_loading_progress_throbber.css);
		@import url(button_effect_scale_onclick.css);
		@import url(blank_page_background.css);
		@import url(autohide_menubar.css);
		@import url(hide_toolbox_top_bottom_borders.css);
		@import url(vertical_context_navigation.css);
		@import url(minimal_popup_scrollbars.css);
		@import url(button_effect_icon_glow.css);
		@import url(dark_context_menus.css);
		@import url(dark_additional_windows.css);
		@import url(dark_checkboxes_and_radios.css);
		@import url(minimal_text_fields.css);
		@import url(minimal_toolbarbuttons.css);
		@import url(urlbar_centered_text.css);

	  /* Remove min,max,close buttons from tabbar*/
	  .titlebar-buttonbox-container { display: none; }

	  :root {
	    --toolbar-bgcolor: rgb(36,44,59) !important;
	    --uc-menu-bkgnd: var(--toolbar-bgcolor);
		  --arrowpanel-background: var(--toolbar-bgcolor) !important;
		  --autocomplete-popup-background: var(--toolbar-bgcolor) !important;
		  --uc-menu-disabled: rgb(90,90,90) !important;
		  --lwt-toolbar-field-focus: rgb(36,44,59) !important;
		}

		#sidebar-box{ --sidebar-background-color: var(--toolbar-bgcolor) !important; }
		window.sidebar-panel{ --lwt-sidebar-background-color: rgb(36,44,59) !important; }
	'';

	force = true;
	};

  programs.firefox = {
    enable = true;

    policies = {
			  DefaultDownloadDirectory = "\${home}/Downloads";    	
				DisableFirefoxAccounts = true;
				DisableTelemetry = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
				DontCheckDefaultBrowser = true;

				EnableTrackingProtection = {
				  Value = true;
				  Cryptomining = true;
				  Fingerprinting = true;
				  EmailTracking = true;
				  Locked = false;
				};

				FirefoxHome = {
					Search = true;
					TopSites = false;
					SponsoredTopSites = false;
					Highlights = false;
					Pocket = false;
					Snippets = false;
					Locked = true;
				};

		    /* ---- EXTENSIONS ---- */
			  ExtensionSettings = {
		  	 "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
		      # uBlock Origin:
			    "uBlock0@raymondhill.net" = {
			      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
			      installation_mode = "force_installed";
			      private_browsing = true;
			    };
			    # Tenhou English UI
			    "{b2faf826-565e-465d-8e7b-dc3857a5ec96}" = {
			    	install_url = "https://addons.mozilla.org/firefox/downloads/latest/tenhou-english-ui/latest.xpi";
			      installation_mode = "force_installed";
			    };
					# add extensions here...
			  };
				
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
				SearchEngines = {
					Default = "DuckDuckGo";
					Add = [
						{
							Alias = "@np";
							Description = "Search in NixOS Packages";
							IconURL = "https://nixos.org/favicon.png";
							Method = "GET";
							Name = "NixOS Packages";
							URLTemplate = "https://search.nixos.org/packages?from=0&size=200&sort=relevance&type=packages&query={searchTerms}";
						}
						{
							Alias = "@no";
							Description = "Search in NixOS Options";
							IconURL = "https://nixos.org/favicon.png";
							Method = "GET";
							Name = "NixOS Options";
							URLTemplate = "https://search.nixos.org/options?from=0&size=200&sort=relevance&type=packages&query={searchTerms}";
						}
					];
				};
		};

    /* ---- PROFILES ---- */
    # Switch profiles via about:profiles page.
    # For options that are available in Home-Manager see
    # https://nix-community.github.io/home-manager/options.html#opt-programs.firefox.profiles
    profiles = {
      profile_0 = {           # choose a profile name; directory is /home/<user>/.mozilla/firefox/profile_0
        id = 0;               # 0 is the default profile; see also option "isDefault"
        name = "profile_0";   # name as listed in about:profiles
        isDefault = true;     # can be omitted; true if profile ID is 0
		    bookmarks = bookmarks;
        settings = commonSettings // {
          "browser.startup.homepage" = "https://nixos.org";
          # add preferences for profile_0 here...
        };
      };
      profile_1 = {
        id = 1;
        name = "Notes";
        isDefault = false;
        settings = commonSettings // {
          "browser.startup.homepage" = "https://duckduckgo.com/";
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        
        # add preferences for profile_1 here...
      };
    # add profiles here...
    };
  };
}
